-- Lua script: /etc/haproxy/scripts/stick_table_reader.lua
core.register_service('stick_table_reader', 'http', function(applet)
    local response = "IP - Request Rate (Last 60s)\n"
    
    -- Lấy stick table và kiểm tra xem nó có tồn tại không
    local stick_table = applet.stick_table
    if not stick_table then
        response = "Stick table not available.\n"
        applet:start_response(500)
        applet:send(response)
        return
    end

    -- Lấy danh sách các keys trong stick table
    local keys = stick_table:get_keys()

    -- Nếu không có keys, trả về thông báo rằng stick table rỗng
    if #keys == 0 then
        response = "Stick table is empty.\n"
    else
        -- Duyệt qua từng key trong stick table
        for _, key in ipairs(keys) do
            -- Lấy giá trị của http_req_rate trong 60s cho mỗi key
            local rate = stick_table:get(key, "http_req_rate(60s)")

            -- Nếu có giá trị, thêm vào phản hồi
            if rate then
                response = response .. key .. " - " .. rate .. "\n"
            else
                response = response .. key .. " - No rate data\n"
            end
        end
    end

    -- Trả về kết quả dưới dạng text
    applet:add_header("Content-Type", "text/plain")
    applet:start_response(200)
    applet:send(response)
end)

