local skynet = require "skynet"


local gate_conf = {
	address = "127.0.0.1", -- 监听地址 127.0.0.1
	port = 8887,
	maxclient = 1024,
	nodelay = true,
}

 skynet.start(function()
 	--redis
 	local redis = skynet.newservice("redis")
 	pcall(skynet.send, redis, "lua", "connet")
 	
 	--gate
	local gateserver = skynet.newservice("gated")
	pcall(skynet.send, gateserver, "lua","start",gate_conf)

	skynet.exit()
end)