local skynet = require "skynet"

local gate_conf = {
	address = "192.168.0.38", -- 监听地址 127.0.0.1
	port = 8887,
	maxclient = 1024,
	nodelay = true,
}

local conf = {
	host = "127.0.0.1" ,
	port = 6379,
	db = 14,
}

 skynet.start(function()
 	--开启日志
 	skynet.newservice("loggerservice")

 	--开启db
 	local db_manager = skynet.newservice("dbmanagerservice")
 	pcall(skynet.send, db_manager, "lua", "start", conf)

 	--gate
	local watchdog = skynet.newservice("watchdog")
	pcall(skynet.send, watchdog, "lua","start",gate_conf)

	skynet.exit()
end)