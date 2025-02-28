core.register_action("verify_request", { "http-req" }, function(txn)
  -- Verify that the request is authorized
  -- Obviously stupid in this case without additional information being sent
  local s = core.tcp()
  
  -- Should be pointing to a frontend with balancing/health checks/etc.
  s:connect("127.0.0.1:8080")
  
  -- We use HTTP 1.0 because we don't support keepalive or any other advanced features in this script.
  s:send("GET /verify.php?url=" .. txn.sf:path() .. " HTTP/1.1\r\nHost: veriy.example.com\r\n\r\n")
  local msg = s:receive("*l")
  
  -- Indicates a connection failure
  if msg == nil then
     -- This leave txn.request_verified unset for potentially different handling
     return
  end
  
  msg = tonumber(string.sub(msg, 9, 12)) -- Read code from 'HTTP/1.0 XXX'
  
  -- Makes it easy to test by making any file to be denied.
  if msg == 404 then
     txn.set_var(txn,"txn.request_verified",true)
  else
     txn.set_var(txn,"txn.request_verified",false)
  end
  
  -- Read the response body, though in this example we aren't using it.
  msg = s:receive("*l")
end)
