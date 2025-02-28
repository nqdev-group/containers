-- Tên file: save_add_ratelimit_headers.lua

local _author = "QuyNH <quynh@vihatgroup.com>"
local _copyright = "Copyright 2017-2020. HAProxy Technologies, LLC."
local _version = "1.0.0"

local function table_to_json(tbl)
    if type(tbl) ~= "table" then
        return '"' .. tostring(tbl) .. '"'  -- Trả về chuỗi nếu không phải là bảng
    end

    local json = "{"
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            json = json .. '"' .. k .. '":'  -- Khóa là chuỗi
        end

        if type(v) == "table" then
            json = json .. table_to_json(v) .. ","  -- Đệ quy cho các bảng lồng nhau
        else
            json = json .. '"' .. tostring(v) .. '",'
        end
    end
    json = json:sub(1, -2) .. "}"  -- Xóa dấu phẩy cuối cùng và đóng ngoặc
    return json
end

-- Lấy thời gian hiện tại và lưu vào biến
core.register_action("set_ratelimit_timestamp", { "http-req" }, function(txn)
    -- local timestamp = os.date("%Y-%m-%d %H:%M:%S") -- (ví dụ: 2024-11-04 15:30:00).
    local timestamp = os.date("%Y%m%d%H%M") -- (ví dụ: 2024-11-04 15:30:00).

    -- Lấy phần mili giây từ os.clock() (mặc dù không phải chính xác tuyệt đối)
    -- local milisec = math.floor(os.clock() * 1000) % 1000  -- Lấy mili giây
    core.Info("set_ratelimit_timestamp -> " .. "os.clock(): " .. os.clock() .. ", current_time: " .. os.date("%Y-%m-%d %H:%M:%S") .. ", time: " .. os.time())

    -- Nối lại chuỗi với phần mili giây
    -- local full_timestamp = timestamp .. string.format("%03d", milisec)  -- Đảm bảo mili giây có 3 chữ số

    -- core.Info("set_ratelimit_timestamp -> " .. "timestamp: " .. timestamp .. ", full_timestamp: " .. full_timestamp)
    txn:set_var("req.ip_request_timestamp", timestamp)
end)

-- Hàm lưu giá trị `req.ip_rate_limit` trong giai đoạn `http-request`
core.register_action("save_ratelimit_req_info", { "http-req" }, function(txn)
  -- Lấy giá trị giới hạn tốc độ và mức sử dụng từ biến yêu cầu
  local rate_limit = txn:get_var("req.ip_rate_limit") or "unknown"  -- Giới hạn tốc độ của IP
  local request_usage = txn:get_var("req.ip_request_usage") or "unknown"  -- Mức sử dụng của IP
  local timestamp = txn:get_var("req.ip_request_timestamp") or "unknown"
  -- core.Info("req -> " .. "rate_limit: " .. rate_limit .. ", request_usage: " .. request_usage)

  -- Lưu giá trị giới hạn và mức sử dụng vào biến giao dịch
  txn:set_var("txn.rate_limit", rate_limit)
  txn:set_var("txn.request_usage", request_usage)
  txn:set_var("txn.request_timestamp", timestamp)
end)

-- Hàm thêm header vào phản hồi, kể cả khi mã trạng thái là 429
core.register_action("save_ratelimit_res_info", { "http-res" }, function(txn)
  -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
  local rate_limit = txn:get_var("txn.rate_limit") or "unknown"  -- Giới hạn tốc độ
  local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
  local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown"
  local remaining = tonumber(rate_limit) - tonumber(request_usage)  -- Tính số yêu cầu còn lại

  -- Ghi log thông tin cho mục đích theo dõi
  -- core.Info("res -> " .. "rate_limit: " .. rate_limit .. ", rate_usage: " .. request_usage .. ", rate_remaining: " .. remaining)

  -- Thêm các header thông tin về giới hạn
  txn.http:res_add_header("x-ratelimit-limit", rate_limit)
  txn.http:res_add_header("x-ratelimit-usage", request_usage)
  txn.http:res_add_header("x-ratelimit-timestamp", request_timestamp)
  -- Thêm header `x-ratelimit-remaining` chỉ khi `remaining` >= 0
  if remaining >= 0 then
    txn.http:res_add_header("x-ratelimit-remaining", tostring(remaining))
  else
    txn.http:res_add_header("x-ratelimit-remaining", tostring(0))
  end
end)

-- Lua script để thêm x-ratelimit headers cho status 429 hoặc chuyển tiếp yêu cầu tới backend
core.register_service("deny_429_ratelimit_headers", "http", function(applet) -- AppletHTTP class
  -- Kiểm tra loại nội dung yêu cầu
  local host = applet.headers["host"][0] or ""  -- Lấy tên máy chủ từ header
  local content_type = applet.headers["content-type"][0] or ""  -- Lấy loại nội dung từ header
  local method = applet.method or ""  -- Phương thức HTTP (GET, POST, ...)
  local requested_path = applet.path or ""  -- Đường dẫn yêu cầu
  local query = applet.qs or ""  -- Các tham số truy vấn

  -- Ghi log thông tin cho mục đích theo dõi
  -- core.Info("http -> " .. "host: " .. host .. ", content_type: " .. content_type .. ", method: " .. method .. ", requested_path: " .. requested_path .. ", query: " .. query)

  -- Đảm bảo rằng txn có tồn tại trước khi truy cập vào các biến
  local limit = applet:get_var("req.ip_rate_limit") or "unknown"  -- Giới hạn tốc độ
  local usage = applet:get_var("req.ip_request_usage") or "unknown"  -- Mức sử dụng
  local remaining = tonumber(limit) - tonumber(usage)  -- Tính số yêu cầu còn lại

  -- Ghi log thông tin cho mục đích theo dõi
  -- core.Info("http -> " .. "rate_limit: " .. limit .. ", request_usage: " .. usage .. ", remaining: " .. remaining)

  -- Thêm các header thông tin về giới hạn
  -- applet:add_header("x-ratelimit-limit", limit)
  -- applet:add_header("x-ratelimit-usage", usage)
  -- applet:add_header("x-ratelimit-remaining", tostring(remaining))

  -- Nội dung phản hồi
  local response
  if content_type == "application/json" then
    -- Nếu content_type là application/json, trả về JSON
    -- response = {
    --   status = 429,
    --   message = "Too Many Requests",
    --   details = "You have sent too many requests in a short period of time. Please try again later.",
    --   rate_limit = limit,
    --   request_usage = usage,
    --   remaining = remaining
    -- }
    -- Sử dụng hàm tự viết để chuyển đổi bảng Lua thành chuỗi JSON
    -- response = table_to_json(response)
    response = '{"status":"429","message":"Too Many Requests","details":"You have sent too many requests in a short period of time. Please try again later.","rate_limit":'..limit..',"rate_remaining":'..remaining..',"rate_usage":'..usage..'}'
    -- core.Info("http -> " .. "response: " .. response)
    applet:add_header("content-type", "application/json")  -- Thiết lập loại nội dung là application/json
  else
    -- Nếu không, trả về HTML
    response = [[
      <html>
        <body>
          <h1>429 Too Many Requests</h1>
          <p>You have sent too many requests in a short period of time. Please try again later.</p>
        </body>
      </html>
    ]]
    applet:add_header("content-type", "text/html")  -- Thiết lập loại nội dung là text/html
  end

  -- Đặt mã trạng thái HTTP là 429 (Too Many Requests)
  applet:set_status(429)
  applet:add_header("content-length", string.len(response))  -- Thiết lập chiều dài nội dung
  
  -- Bắt đầu phản hồi và gửi nội dung
  applet:start_response()
  applet:send(response)
end)
