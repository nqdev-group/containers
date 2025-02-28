-- Tên file: 429_ratelimit_headers.lua

-- Đăng ký dịch vụ phản hồi khi gặp lỗi 429
core.register_service("429_ratelimit_headers", "http", function(applet)
    local txn = applet.txn
    
    -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
    local rate_limit = txn:get_var("txn.rate_limit") or "unknown"
    local request_usage = txn:get_var("txn.request_usage") or "unknown"
    local remaining = tonumber(rate_limit) - tonumber(request_usage)
    
    -- Ghi log thông tin cho mục đích theo dõi
    core.Info("429 -> rate_limit: " .. rate_limit .. ", request_usage: " .. request_usage)

    -- Thêm các header thông tin về giới hạn
    applet:add_header("x-ratelimit-limit", rate_limit)
    applet:add_header("x-ratelimit-usage", request_usage)
    applet:add_header("x-ratelimit-remaining", tostring(remaining))

    -- Nội dung phản hồi
    local response = "Request was rate-limited. Please wait before retrying.\n"
    
    -- Thiết lập mã trạng thái và các tiêu đề cần thiết
    applet:set_status(429)
    applet:add_header("content-length", #response)
    applet:add_header("content-type", "text/plain")
    
    -- Bắt đầu gửi phản hồi
    applet:start_response()
    applet:send(response)
end)
