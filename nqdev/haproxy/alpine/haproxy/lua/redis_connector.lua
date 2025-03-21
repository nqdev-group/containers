local redis = require "redis"  -- Sử dụng thư viện redis-lua

-- Import the cidr_check.lua file
dofile("/nqdev/haproxy/lua/cidr_check.lua")

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
        print("Xác thực Redis thất bại: " .. err)
        return
    end
end

-- Kiểm tra kết nối Redis
local ok, err = client:ping()
if not ok then
    print("Không thể kết nối Redis: " .. err)
    return
else
    print("Kết nối Redis thành công!")
end

-- Thử ghi dữ liệu vào Redis với thời gian hết hạn (ví dụ 10 giây)
local key = "test_key"
local value = "test_value"
local ttl = 100  -- Thời gian sống của key trong Redis (số giây)

-- Ghi dữ liệu vào Redis với thời gian hết hạn
local ok, err = client:setex(key, ttl, value)
if not ok then
    print("Lỗi khi ghi vào Redis: " .. err)
    return
else
    print("Dữ liệu đã được ghi vào Redis với thời gian hết hạn thành công!")
end

-- Đọc lại dữ liệu từ Redis để xác nhận việc ghi
local stored_value, err = client:get(key)
if stored_value == nil then  -- Kiểm tra xem có giá trị trong Redis không
    print("Không thể đọc giá trị từ Redis: " .. err)
    return
else
    print("Đọc giá trị từ Redis thành công: " .. stored_value)
end

-- Kiểm tra thời gian hết hạn của key
local ttl_remaining, err = client:ttl(key)
if ttl_remaining == -1 then
    print("Key không có thời gian hết hạn.")
elseif ttl_remaining == -2 then
    print("Key đã bị xóa do hết hạn.")
else
    print("Thời gian còn lại của key là " .. ttl_remaining .. " giây.")
end

-- Xoá key để dọn dẹp
-- client:del(key)
-- print("Đã xoá key '" .. key .. "' khỏi Redis.")

-- =============================================================================
-- Example of using the cidr_match function from cidr_check.lua
local ip = "192.168.1.100"
local cidr = "192.168.1.0/24"

if cidr_match(ip, cidr) then
    print("cidr_match: " .. ip .. " is within the CIDR range " .. cidr)
else
    print("cidr_match: " .. ip .. " is NOT within the CIDR range " .. cidr)
end

ip = "192.168.2.100"
if cidr_match(ip, cidr) then
    print("cidr_match: " .. ip .. " is within the CIDR range " .. cidr)
else
    print("cidr_match: " .. ip .. " is NOT within the CIDR range " .. cidr)
end

if cidr_match("hjakhka", "aaaa") then
    print("cidr_match: " .. 'hjakhka' .. " is within the CIDR range " .. 'aaaa')
else
    print("cidr_match: " .. 'hjakhka' .. " is NOT within the CIDR range " .. 'aaaa')
end
