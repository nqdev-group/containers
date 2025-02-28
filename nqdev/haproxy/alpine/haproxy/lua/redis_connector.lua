-- Cập nhật package.path để Lua tìm thấy redis.lua
-- package.path = package.path .. ";/usr/local/lib/lua/5.4/lua-isa/?.lua"
-- package.path = package.path .. ";/usr/local/lib/lua/5.4/lua-redis/?.lua"

-- Sử dụng module redis
local redis = require "redis"

-- Cấu hình giới hạn tốc độ (requests per second)
local rate_limit = 10
local rate_window = 10  -- Giới hạn thời gian (giây)

-- Kết nối Redis (sử dụng Redis default port 6379)
local redis_host = "192.168.2.53"
local redis_port = 7788
local redis_password = "OvgvI256QnCAYUgzlq"

-- Kết nối tới Redis
local client = redis.connect(redis_host, redis_port)

-- Nếu Redis yêu cầu xác thực, thực hiện xác thực
if redis_password then
  local success, err = client:auth(redis_password)
  if not success then
    print("Redis authentication failed: " .. err)
    client:quit()
    return  -- Dừng lại nếu xác thực thất bại
  end
end

-- Gửi lệnh PING tới Redis để kiểm tra kết nối
local success, err = client:ping()
if not success then
  print("Failed to connect to Redis: " .. err)
else
  client:select(0)
  client:set('usr:nrk', 0)
  local value = client:get('usr:nrk')
  print("Redis Response: " .. value)  -- Nếu thành công, in ra phản hồi "PONG"
end

-- Đóng kết nối Redis
client:quit()
