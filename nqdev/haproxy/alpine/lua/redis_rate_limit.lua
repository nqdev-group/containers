local redis = require "redis"  -- Sử dụng thư viện redis-lua (https://github.com/mah0x211/lua-redis)

-- Import the cidr_check.lua file
dofile("/nqdev/haproxy/lua/cidr_check.lua")

-- Lưu ý: Các giá trị này có thể được cấu hình trong Docker Compose hoặc Kubernetes
-- Lưu ý: Bạn cũng có thể cấu hình trực tiếp trong mã Lua này
local redis_host = os.getenv("REDIS_HOST") or "127.0.0.1"  -- Mặc định là localhost nếu không có giá trị
local redis_port = tonumber(os.getenv("REDIS_PORT") or 6379)  -- Mặc định là 6379 nếu không có giá trị
local redis_password = os.getenv("REDIS_PASSWORD")  -- Lấy mật khẩu từ biến môi trường REDIS_PASSWORD

-- Giới hạn tỷ lệ (rate limit) và cửa sổ thời gian (rate window)
-- Lưu ý: Bạn có thể cấu hình giới hạn tỷ lệ và cửa sổ thời gian trong mã Lua này hoặc thông qua biến môi trường
local rate_window = 60  -- Giới hạn thời gian (giây)
local rate_map = {} -- Biến toàn cục rate_map. Bảng lưu trữ giới hạn tỷ lệ cho từng IP (key: IP, value: rate limit)

-- Summary: Hàm tải bảng ánh xạ rate_map từ file map (nếu có)
-- Return: Bảng ánh xạ rate_map (key: IP, value: rate limit)
-- Params: Đường dẫn tới file map chứa thông tin về giới hạn tỷ lệ cho từng IP
-- Note: Hàm này sử dụng bảng rate_map để lưu trữ giới hạn tỷ lệ cho từng IP (key: IP, value: rate limit) từ file map (nếu có) hoặc cấu hình trực tiếp trong mã Lua này (nếu không có).
function load_rate_limit_map(filename)
  -- Kiểm tra xem đã tải bảng rate_map chưa
  if next(rate_map) ~= nil then
    return rate_map  -- Nếu đã có giá trị trong bảng, trả về luôn
  end

  -- Mở file và đọc từng dòng
  local file = io.open(filename, "r")
  if not file then
    -- Nếu file không tồn tại, cảnh báo và tiếp tục
    -- core.Warn("Unable to open rate limit map file: " .. filename .. ". Using default settings.")
    return rate_map  -- Không thay đổi bảng rate_map, giữ mặc định
  end

  -- Đọc từng dòng trong file
  for line in file:lines() do
    -- Loại bỏ các dòng trống hoặc comment
    if line ~= "" and not line:match("^#") then
      local ip, rate_limit = line:match("^(%S+)%s+(%S+)")
      if ip and rate_limit then
        -- Chuyển đổi rate_limit thành số nếu có thể, nếu không, đặt giá trị mặc định là -1
        rate_limit = tonumber(rate_limit) or -1
        rate_map[ip] = rate_limit
      end
    end
  end

  -- Đóng file
  file:close()

  return rate_map
end

-- Summary: Hàm lấy giới hạn tỷ lệ (rate limit) cho từng địa chỉ IP (IP address)
-- Return: Giới hạn tỷ lệ (rate limit) hoặc 10 nếu không tìm thấy IP trong bảng ánh xạ
-- Params: Địa chỉ IP của client (IP address)
-- Note: Hàm này sử dụng bảng rate_map để lưu trữ giới hạn tỷ lệ cho từng IP (key: IP, value: rate limit) từ file map (nếu có) hoặc cấu hình trực tiếp trong mã Lua này (nếu không có).
function get_rate_limit_for_ip(ip)
  local rate_limit = 10 -- Default rate limit if no match is found

  -- First, check if the IP exists directly in the rate_map
  if rate_map[ip] then
    return rate_map[ip] -- Return the rate limit if an exact match is found
  end

  -- If no exact match, check if the IP belongs to any CIDR range in the rate_map
  for range, limit in pairs(rate_map) do
    if cidr_match(ip, range) then -- Check if the IP is in the CIDR range
      return limit -- Return the rate limit for the matching CIDR range
    end
  end

  -- If no match found, return the default rate limit
  return rate_limit
end

-- Summary: Hàm lấy địa chỉ IP của client từ biến giao dịch (txn)
-- Return: Địa chỉ IP của client hoặc "unknown_ip" nếu không tìm thấy
-- Params: Biến giao dịch (txn) chứa thông tin về yêu cầu và phản hồi HTTP
-- Note: Hàm này sử dụng header X-HaEsms-Forwarded-For để lấy địa chỉ IP của client (nếu có)
-- Note: Hàm này sử dụng header X-Forwarded-For để lấy địa chỉ IP của client (nếu có)
-- Note: Hàm này sử dụng biến giao dịch (txn) để lưu thông tin về địa chỉ IP
function get_client_ip(txn)
  local ip = txn.f:hdr("X-HaEsms-Forwarded-For")
  if ip then
    -- Nếu có nhiều IP, lấy IP đầu tiên (địa chỉ của client thực sự)
    ip = ip:match("^[^,]+")
  end

  -- Kiểm tra IP từ txn (Get source IP)
  -- local ip = txn.f:src()

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

-- Summary: Hàm lấy giá trị của header từ biến giao dịch (txn)
-- Return: Giá trị của header hoặc "unknown" nếu không tìm thấy
-- Params:
--  + headers: Bảng chứa thông tin về các header của yêu cầu HTTP
--  + header_name: Tên của header cần lấy giá trị
-- Note: Hàm này sử dụng biến giao dịch (txn) để lưu thông tin về giá trị header (nếu có) hoặc "unknown" nếu không tìm thấy header đó trong yêu cầu HTTP của client.
function get_header_value(headers, header_name)
  -- Kiểm tra nếu headers không phải là table hoặc không phải kiểu của applet.headers
  if type(headers) ~= "table" or not headers[header_name] then
    return "unknown"
  end

  -- Trả về giá trị của header nếu có, hoặc "unknown" nếu không tồn tại
  return headers[header_name][0] or "unknown"
end

-- Summary: Hàm kiểm tra giới hạn tỷ lệ (rate limit) cho mỗi yêu cầu từ client IP cụ thể (client_ip) và biến giao dịch (txn)
-- Return: Hàm này trả về
--  + true (rate limit OK) nếu chưa vượt quá giới hạn tỷ lệ (rate limit) và tiếp tục xử lý yêu cầu,
--  + false (rate limit exceeded) nếu đã vượt quá giới hạn tỷ lệ và từ chối yêu cầu
-- Params:
--  + client_ip: Địa chỉ IP của client (được sử dụng làm key để lưu trữ thông tin giới hạn tỷ lệ)
--  + txn: Biến giao dịch (transaction) chứa thông tin về yêu cầu và phản hồi HTTP
-- Note: Hàm này sử dụng biến môi trường để cấu hình Redis (host, port, password)
-- Note: Hàm này sử dụng bảng ánh xạ rate_map để lưu trữ giới hạn tỷ lệ cho từng IP (key: IP, value: rate limit) từ file map (nếu có) hoặc cấu hình trực tiếp trong mã Lua này (nếu không có)
-- Note: Hàm này sử dụng thư viện redis-lua để kết nối và thao tác với Redis (đếm số lượng yêu cầu)
-- Note: Hàm này sử dụng hàm get_client_ip để lấy địa chỉ IP của client từ biến giao dịch (txn)
-- Note: Hàm này sử dụng biến giao dịch (txn) để lưu thông tin về giới hạn tỷ lệ
function rate_limit_check(client_ip, txn)
  -- local client_ip = get_client_ip(txn) -- Lấy IP của client từ txn
  local host = txn.f:hdr("Host") or "unknown"  -- Lấy host từ biến giao dịch (txn)
  local redis_key = "rate_limit_"..host..":" .. client_ip  -- Key Redis dùng để đếm yêu cầu
  -- local client_key = txn.f:hdr("x-client-key") or "unknown"  -- Lấy client key từ biến giao dịch (txn)

  -- Kiểm tra nếu IP là "unknown" hoặc "unknown_ip" hoặc rỗng, không giới hạn yêu cầu, cho phép tiếp tục
  if client_ip == "unknown" or client_ip == "unknown_ip" or client_ip == "" then
    -- Không giới hạn yêu cầu, cho phép tiếp tục
    return true
  end

  -- Lấy bảng ánh xạ từ file map (nếu chưa có, nó sẽ tải một lần)
  load_rate_limit_map("/nqdev/haproxy/map/ipclient-rates.map")

  -- Kiểm tra giới hạn yêu cầu cho địa chỉ IP
  local client_ip_rate_limit = get_rate_limit_for_ip(client_ip)  -- Lấy giới hạn yêu cầu cho IP
  -- print("client_ip_rate_limit: " .. client_ip_rate_limit .. ", client_ip: " .. client_ip)

  if client_ip_rate_limit == -1 then
    -- Không giới hạn yêu cầu, cho phép tiếp tục
    return true
  end

  -- Kết nối đến Redis
  local client = redis.connect({
      host = redis_host,
      port = redis_port
  })

  -- Xác thực với Redis (nếu mật khẩu được yêu cầu)
  if redis_password then
    local ok, err = client:auth(redis_password)
    if not ok then
        -- Nếu xác thực Redis thất bại, trả về true (tiếp tục xử lý yêu cầu)
        return true
    end
  end

  -- Lấy số lượng yêu cầu trong cửa sổ thời gian hiện tại
  local request_count = tonumber(client:get(redis_key) or 0)
  local current_time = os.time()  -- Thời gian hiện tại
  local request_remaining = tonumber(client_ip_rate_limit) - tonumber(request_count) -- Số lượng yêu cầu còn lại

  -- Lưu giá trị giới hạn và mức sử dụng vào biến giao dịch
  txn:set_var("txn.rate_redis_key", redis_key)
  txn:set_var("txn.rate_limit", client_ip_rate_limit)
  txn:set_var("txn.rate_window", rate_window)
  txn:set_var("txn.request_usage", request_count + 1)
  txn:set_var("txn.request_timestamp", current_time)
  txn:set_var("txn.request_remaining", request_remaining)
  txn:set_var("txn.request_client_ip", client_ip)
  -- txn:set_var("txn.request_client_key", client_key)

  -- Kiểm tra nếu đã vượt quá giới hạn
  if request_count >= client_ip_rate_limit then
    -- Ghi log thông tin về việc vượt quá giới hạn
    -- core.Debug("Rate limit exceeded for client " .. client_ip .. " (" .. request_count .. "/" .. rate_limit .. ")")

    -- Tăng số lượng yêu cầu (không cập nhật thời gian hết hạn)
    client:incr(redis_key)
    -- client:incr("check:"..client_key..":_req:"..client_ip)
    -- client:incr("check:"..client_key..":_fail:"..client_ip)

    -- Đóng kết nối Redis sau khi sử dụng xong (để giải phóng tài nguyên)
    client:quit()

    -- Trả về false để từ chối yêu cầu (rate limit exceeded) và chuyển hướng về phía client (HTTP 429)
    return false
  else
    -- Ghi log thông tin về việc chưa vượt quá giới hạn
    -- core.Debug("Rate limit OK for client " .. client_ip .. " (" .. request_count .. "/" .. rate_limit .. ")")

    -- Nếu chưa vượt quá giới hạn, tăng số lượng yêu cầu và thiết lập thời gian hết hạn (expire)
    client:incr(redis_key)
    client:expire(redis_key, rate_window)  -- Thiết lập thời gian hết hạn cho key
    -- client:incr("check:"..client_key..":_req:"..client_ip)
    -- client:incr("check:"..client_key..":_pass:"..client_ip)

    -- Đóng kết nối Redis sau khi sử dụng xong (để giải phóng tài nguyên)
    client:quit()

    -- Trả về true để tiếp tục xử lý yêu cầu bình thường (rate limit OK)
    return true
  end
end

-- Summary: Hàm kiểm tra giới hạn tỷ lệ (rate limit) cho mỗi yêu cầu từ biến giao dịch (txn)
-- Return: Hàm này trả về
--  + true (rate limit OK) nếu chưa vượt quá giới hạn tỷ lệ (rate limit) và tiếp tục xử lý yêu cầu,
--  + false (rate limit exceeded) nếu đã vượt quá giới hạn tỷ lệ và từ chối yêu cầu
-- Params: Biến giao dịch (transaction) chứa thông tin về yêu cầu và phản hồi HTTP
-- Note: Hàm này sử dụng hàm get_client_ip để lấy địa chỉ IP của client từ biến giao dịch (txn)
-- Note: Hàm này sử dụng hàm rate_limit_check để kiểm tra giới hạn tỷ lệ từ địa chỉ IP của client
-- Note: Hàm này sử dụng biến giao dịch (txn) để lưu thông tin về giới hạn tỷ lệ
function txn_rate_limit_check(txn)
  -- Lấy IP của client từ txn (có thể sử dụng txn.sf:ip() hoặc gọi một hàm get_client_ip nếu cần)
  -- local client_ip = txn.sf:ip()  -- Lấy IP của client từ txn
  local client_ip = get_client_ip(txn) -- Lấy IP của client

  -- Kiểm tra giới hạn tỷ lệ (sử dụng hàm rate_limit_check)
  local status, result = pcall(function()
    return rate_limit_check(client_ip, txn) -- Hàm kiểm tra rate limit
  end)

  if status then
    -- Nếu không có lỗi, trả về kết quả của hàm rate_limit_check
    return result -- true (rate limit OK) hoặc false (rate limit exceeded)
  else
    -- Nếu có lỗi, xử lý và trả về false hoặc giá trị mặc định
    -- Bạn có thể ghi log lỗi hoặc thực hiện các hành động khác tại đây
    -- print("Error occurred during rate limit check: " .. result)
    return true  -- Hoặc bạn có thể xử lý lỗi theo cách khác
  end
end

-- Summary: Hàm này sẽ được gọi khi HAProxy gặp các sự kiện như http-req (yêu cầu HTTP)
-- để kiểm tra giới hạn tỷ lệ (rate limit) cho mỗi yêu cầu từ client IP cụ thể (client_ip)
-- và biến giao dịch (txn) để lưu thông tin về giới hạn tỷ lệ và thời gian sử dụng.
core.register_action("action_ratelimit_req_check", { "http-req" }, function(txn)
  if not txn then
    -- core.Debug("Transaction object is nil")
    return
  end

  if not txn_rate_limit_check(txn) then
    -- Nếu vượt quá giới hạn tỷ lệ, trả về false để từ chối yêu cầu
    -- core.Debug("Rate limit exceeded, reject request")

    -- Đánh dấu yêu cầu bị từ chối vì vượt quá giới hạn tỷ lệ (rate limit)
    txn:set_var("txn.is_rate_limit_reject_req", "true")

    -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
    -- local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
    -- local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown" -- Thời gian sử dụng
  else
    -- Nếu không vượt quá giới hạn tỷ lệ, tiếp tục xử lý bình thường
    -- core.Debug("Rate limit OK, continue processing request")

    -- Đánh dấu yêu cầu không bị từ chối vì vượt quá giới hạn tỷ lệ (rate limit)
    txn:set_var("txn.is_rate_limit_reject_req", "false")

    -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
    -- local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
    -- local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown" -- Thời gian sử dụng
  end

end)

-- Summary: Hàm này sẽ được gọi khi HAProxy gặp các sự kiện như http-res (phản hồi HTTP)
-- để thêm thông tin về giới hạn tỷ lệ vào phản hồi HTTP (response) cho client biết về giới hạn tỷ lệ
-- và số yêu cầu còn lại (remaining) trong cửa sổ thời gian hiện tại (rate window)
-- và thông tin về mức sử dụng (request usage) và thời gian sử dụng (request timestamp).
core.register_action("action_ratelimit_res_check", { "http-res" }, function(txn)
  if not txn then
    -- core.Debug("Transaction object is nil")
    return
  end

  -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
  local rate_limit = txn:get_var("txn.rate_limit") or "unknown"  -- Giới hạn tốc độ
  local rate_window = txn:get_var("txn.rate_window") or "unknown"  -- Giới hạn tốc độ
  local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
  local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown" -- Thời gian sử dụng
  local is_rate_limit_reject_req = txn:get_var("txn.is_rate_limit_reject_req") or "unknown" -- Yêu cầu bị từ chối vì vượt quá giới hạn tỷ lệ

  -- Nếu giới hạn tỷ lệ là -1 hoặc không xác định, không cần thêm thông tin về giới hạn vào phản hồi
  if rate_limit == "-1" or rate_limit == "unknown" then
    -- Nếu không giới hạn yêu cầu, không cần thêm thông tin về giới hạn vào phản hồi
    return
  end

  local remaining = tonumber(rate_limit) - tonumber(request_usage)  -- Tính số yêu cầu còn lại

  -- Ghi log thông tin cho mục đích theo dõi
  -- core.Debug("res -> " .. "rate_limit: " .. rate_limit .. ", rate_window: " .. rate_window .. ", request_usage: " .. request_usage .. ", request_timestamp: " .. request_timestamp, ", is_rate_limit_reject_req: " .. is_rate_limit_reject_req, ", remaining: " .. remaining)

  -- Thêm các header thông tin về giới hạn
  txn.http:res_add_header("x-ratelimit-limit", rate_limit)
  txn.http:res_add_header("x-ratelimit-retry-after", rate_window)
  txn.http:res_add_header("x-ratelimit-usage", request_usage)
  txn.http:res_add_header("x-ratelimit-timestamp", request_timestamp)
  -- txn.http:res_add_header("x-ratelimit-client_ip", txn:get_var("txn.request_client_ip") or "unknown")
  -- txn.http:res_add_header("x-ratelimit-client_key", txn:get_var("txn.request_client_key") or "unknown")

  -- Thêm header `x-ratelimit-remaining` để thông báo số yêu cầu còn lại
  if is_rate_limit_reject_req == "true" then
    txn.http:res_add_header("x-ratelimit-remaining", tostring(0))
  else
    txn.http:res_add_header("x-ratelimit-remaining", tostring(remaining))
  end
end)

core.register_service("action_ratelimit_check_deny_429", "http", function(applet) -- AppletHTTP class
  local method = applet.method or ""  -- Phương thức yêu cầu (method) như GET, POST, PUT, DELETE ...
  local path = applet.path or ""  -- Đường dẫn yêu cầu (path)
  local query = applet.qs or ""  -- Các tham số truy vấn (query string) nếu có (sau dấu ?)
  local uri = applet.uri or ""  -- Đường dẫn yêu cầu đầy đủ (full URI)
  local url = applet.url or ""  -- URL yêu cầu đầy đủ (full URL)
  local scheme = applet.scheme or ""  -- Giao thức yêu cầu (http hoặc https)
  local port = applet.port or ""  -- Cổng yêu cầu (port)
  local client_ip = applet.peer or "unknown_ip" -- Địa chỉ IP của client (client IP) hoặc "unknown_ip" nếu không tìm thấy

  local host = get_header_value(applet.headers, "host") -- Host của client (nếu có) hoặc "unknown" nếu không tìm thấy
  local content_type = get_header_value(applet.headers, "content-type") -- Loại nội dung (content type) của client (nếu có) hoặc "unknown" nếu không tìm thấy
  local user_agent = get_header_value(applet.headers, "user-agent") -- User-Agent của client (nếu có)
  local accept = get_header_value(applet.headers, "accept") -- Accept của client (nếu có)
  local accept_language = get_header_value(applet.headers, "accept-language") -- Accept-Language của client (nếu có)
  local accept_encoding = get_header_value(applet.headers, "accept-encoding") -- Accept-Encoding của client (nếu có)
  local accept_charset = get_header_value(applet.headers, "accept-charset") -- Accept-Charset của client (nếu có)
  local connection = get_header_value(applet.headers, "connection") -- Connection của client (nếu có)
  local referer = get_header_value(applet.headers, "referer") -- Referer của client (nếu có)
  local cookie = get_header_value(applet.headers, "cookie") -- Cookie của client (nếu có)

  -- Ghi log thông tin về yêu cầu từ client (client request)
  -- print("host: " .. host .. ", content_type: " .. content_type .. ", user_agent: " .. user_agent .. ", accept: " .. accept .. ", accept_language: " .. accept_language .. ", accept_encoding: " .. accept_encoding .. ", accept_charset: " .. accept_charset .. ", connection: " .. connection .. ", referer: " .. referer .. ", cookie: " .. cookie)

  -- Nội dung phản hồi
  local response
  if content_type == "application/json" then
    -- Nếu yêu cầu là JSON, trả về JSON
    applet:add_header("content-type", "application/json")
    if host == "rest.esms.vn" or host == "nqdev.local:10080" then
      response = '{"CodeResult":"429","Message":" Too Many Requests","ErrorMessage":"You have sent too many requests in a short period of time. Please try again later."}'
    else
      response = '{"status":"429","message":"Too Many Requests","details":"You have sent too many requests in a short period of time. Please try again later."}'
    end
  elseif content_type == "application/xml" or content_type == "text/xml" then
    -- Nếu yêu cầu là XML, trả về phản hồi dưới dạng XML
    applet:add_header("content-type", "application/xml")
    if host == "rest.esms.vn" then
      response = [[
        <response>
          <CodeResult>429</CodeResult>
          <Message>Too Many Requests</Message>
          <ErrorMessage>You have sent too many requests in a short period of time. Please try again later.</ErrorMessage>
        </response>
      ]]
    else
      response = [[
        <response>
          <status>429</status>
          <message>Too Many Requests</message>
          <details>You have sent too many requests in a short period of time. Please try again later.</details>
        </response>
      ]]
    end
  elseif content_type == "text/plain" then
    -- Nếu yêu cầu là text/plain, trả về văn bản thuần túy
    applet:add_header("content-type", "text/plain")
    response = [[
      429 Too Many Requests
      You have sent too many requests in a short period of time. Please try again later.
    ]]
  else
    -- Mặc định trả về HTML
    applet:add_header("content-type", "text/html")  -- Thiết lập loại nội dung là text/html
    response = [[
      <html>
        <body>
          <h1>429 Too Many Requests</h1>
          <p>You have sent too many requests in a short period of time. Please try again later.</p>
        </body>
      </html>
    ]]
  end

  -- Đặt mã trạng thái HTTP là 429 (Too Many Requests)
  applet:set_status(429) -- HTTP 429 Too Many Requests
  applet:add_header("content-length", string.len(response))  -- Thiết lập chiều dài nội dung

  -- Bắt đầu phản hồi và gửi nội dung
  applet:start_response()
  applet:send(response)
end)

-- Summary: Hàm này sẽ được gọi khi HAProxy gặp các sự kiện như http-res (phản hồi HTTP)
core.register_action("action_ratelimit_handle_redirect", {"http-res"}, function(txn)
  -- Kiểm tra txn có hợp lệ không
  if not txn then
    -- Nếu txn không hợp lệ, trả về ngay
    return
  end

  -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
  local redis_key = txn:get_var("txn.rate_redis_key") or "unknown"  -- Giới hạn tốc độ
  local rate_limit = txn:get_var("txn.rate_limit") or "unknown"  -- Giới hạn tốc độ
  local rate_window = txn:get_var("txn.rate_window") or "unknown"  -- Giới hạn tốc độ
  local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
  local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown" -- Thời gian sử dụng
  local is_rate_limit_reject_req = txn:get_var("txn.is_rate_limit_reject_req") or "unknown" -- Yêu cầu bị từ chối vì vượt quá giới hạn tỷ lệ

  -- Nếu giới hạn tỷ lệ là -1 hoặc không xác định, không cần thêm thông tin về giới hạn vào phản hồi
  if rate_limit == "-1" or rate_limit == "unknown" then
    -- Nếu không giới hạn yêu cầu, không cần thêm thông tin về giới hạn vào phản hồi
    return
  end

  -- Kết nối đến Redis
  local client = redis.connect({
      host = redis_host,
      port = redis_port
  })

  -- Xác thực với Redis (nếu mật khẩu được yêu cầu)
  if redis_password then
    local ok, err = client:auth(redis_password)
    if not ok then
        -- Nếu xác thực Redis thất bại, trả về true (tiếp tục xử lý yêu cầu)
        return true
    end
  end

  -- Tiến hành pipeline Redis (cũng sử dụng pcall để bảo vệ)
  local replies, pipe_err = pcall(function()
    return client:pipeline(function(p)
      p:incrby(redis_key, -1)
    end)
  end)

  -- Đóng kết nối Redis sau khi sử dụng xong (để giải phóng tài nguyên)
  local quit_ok, quit_err = pcall(function()
    return client:quit()
  end)

  -- Thêm header vào response
  -- txn.http:res_add_header("x-ratelimit-handle_redirect", 'true')
end)
