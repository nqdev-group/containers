-- 200.lua
core.register_service("200-response", "http", function(applet)
    local response = ""
    applet:set_status(200)
    applet:add_header("Content-Length", string.len(response))  -- Thiết lập chiều dài nội dung
    applet:start_response()
    applet:send(response)
end)
