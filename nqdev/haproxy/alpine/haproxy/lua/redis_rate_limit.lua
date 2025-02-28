-- Cấu hình giới hạn tốc độ (requests per second)
local rate_limit = 10
local rate_window = 10  -- Giới hạn thời gian (giây)

-- Kết nối Redis (sử dụng Redis default port 6379)
local redis_host = "192.168.2.53"
local redis_port = 7788
local redis_password = "OvgvI256QnCAYUgzlq"

-- Helper function để lấy địa chỉ IP của client
function get_client_ip(txn)
  -- Kiểm tra IP từ txn (Get source IP)
  local ip = txn.f:src()

  -- Nếu không có, lấy từ header X-Forwarded-For (dùng cho proxy)
  if not ip then
    local forwarded_for = txn.f:hdr("X-Forwarded-For")  -- Sử dụng txn.f:hdr() thay vì get_header
    if forwarded_for then
      -- Nếu có nhiều IP, lấy IP đầu tiên (địa chỉ của client thực sự)
      ip = forwarded_for:match("^[^,]+")
    end
  end

  -- Nếu không có IP trong cả txn và header, trả về nil
  return ip or "unknown_ip"
end

-- Kiểm tra rate limit
function check_rate_limit(txn)
  local client_ip = get_client_ip(txn)
  local redis_key = "rate_limit:" .. client_ip  -- Key Redis dùng để đếm yêu cầu

  -- Kết nối Redis
  local redis = require "redis"
  local redis_client = redis.connect(redis_host, redis_port)

  -- Xác thực với Redis (nếu mật khẩu được yêu cầu)
  if redis_password then
    local auth_res, err = redis_client:auth(redis_password)
    if not auth_res then
      txn:log("Redis authentication failed: " .. err)
      redis_client:close()
      return true  -- Block request
    end
  end

  -- Lấy số lượng yêu cầu trong cửa sổ thời gian hiện tại
  local request_count = redis_client:get(redis_key) or 0
  local current_time = os.time()

  -- Kiểm tra nếu đã vượt quá giới hạn
  if tonumber(request_count) >= rate_limit then
    txn:log("Rate limit exceeded for IP: " .. client_ip)
    redis_client:close()
    return true  -- Block request
  else
    -- Incremement request count và thiết lập thời gian hết hạn (expire)
    redis_client:incr(redis_key)
    redis_client:expire(redis_key, rate_window)  -- Thiết lập thời gian hết hạn cho key
    redis_client:close()
    return false  -- Allow request
  end
end

-- Áp dụng kiểm tra rate limit cho mỗi yêu cầu
core.register_action("rate_limit_check", { "http-req" }, function(txn)
  if check_rate_limit(txn) then
    txn:set_resp_status(429)  -- HTTP 429 Too Many Requests
    txn:add_header("Content-Type", "text/plain")
    txn:add_header("X-Rate-Limit", rate_limit)
    txn:add_header("Retry-After", rate_window)  -- seconds
    txn:send_response("Rate limit exceeded")
  end
end)
