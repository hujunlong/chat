local skynet = require "skynet"

local gate_conf = {
	address = "192.168.0.38", -- 监听地址 127.0.0.1
	port = 8888,
	maxclient = 1024,
	nodelay = true,
}

 skynet.start(function()
 	--开启日志
 	skynet.newservice("loggerservice")

 	--开启聊天服务
 	skynet.newservice("chatservice")
 	
	local watchdog = skynet.newservice("watchdog")
	pcall(skynet.send, watchdog, "lua","start",gate_conf)

	skynet.exit()
end)

 
 
 