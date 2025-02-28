-- Ten file: capture_response_info.lua

core.register_action("capture_response_info", { "http-res" }, function(txn)
    -- Ghi mã trạng thái của phản hồi
    -- local status = txn.res:get_status()
    -- core.Info("HTTP Status: " .. status)

    -- Ghi tiêu đề "Content-Type" của phản hồi nếu có
    -- local content_type = txn.res:get_headers("Content-Type")[0] or "unknown"
    -- core.Info("Content-Type: " .. content_type)

    -- Ghi tiêu đề bổ sung khác nếu cần
    -- local custom_header = txn.res:get_headers("X-Custom-Header")[0] or "N/A"
    -- core.Info("Custom Header: " .. custom_header)

    -- core.Info("something data")

    -- Lưu ý: Không thể ghi lại `body` của phản hồi.
end)

