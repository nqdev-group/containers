local redis = require "redis"  -- Sử dụng thư viện redis-lua

-- Lấy các giá trị biến môi trường từ Docker Compose
local redis_host = os.getenv("REDIS_HOST") or "127.0.0.1"  -- Mặc định là localhost nếu không có giá trị
local redis_port = tonumber(os.getenv("REDIS_PORT") or 6379)  -- Mặc định là 6379 nếu không có giá trị
local redis_password = os.getenv("REDIS_PASSWORD")  -- Lấy mật khẩu từ biến môi trường REDIS_PASSWORD

-- Kết nối đến Redis
local client = redis.connect({
  host = redis_host,
  port = redis_port
})

-- Nếu Redis yêu cầu mật khẩu, thực hiện xác thực
if redis_password then
    local ok, err = client:auth(redis_password)
    if not ok then
        core.debug("Xác thực Redis thất bại: " .. err)
        return
    end
end

-- Kiểm tra kết nối Redis
local ok, err = client:ping()
if not ok then
    core.debug("Không thể kết nối Redis: " .. err)
    return
end

-- Lấy IP của client từ request
local client_ip = core.client_ip()

-- Đặt tên key cho bộ đếm rate limit, sử dụng IP của client
local key = "rate_limit:" .. client_ip
local limit = 10  -- Giới hạn số yêu cầu trong 1 giây

-- Lấy giá trị hiện tại của bộ đếm
local current, err = client:get(key)

if current == ngx.null then
    -- Nếu chưa có bộ đếm, khởi tạo
    client:set(key, 1)
    client:expire(key, 1)  -- Đặt thời gian hết hạn của bộ đếm là 1 giây
else
    current = tonumber(current)
    if current >= limit then
        -- Nếu vượt quá giới hạn, trả về lỗi 429 Too Many Requests
        core.response.set_status(429)
        core.response.set_body("Rate limit exceeded. Try again later.")
        core.response.send()
        return
    else
        -- Nếu chưa vượt quá, tăng bộ đếm
        client:incr(key)
    end
end
