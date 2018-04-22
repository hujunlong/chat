local skynet = require "skynet"
local cluster = require "cluster"
--local parser = require "parser"

function deal_cluster()
	cluster.open "db"
end


local gate_conf = {
	address = "127.0.0.1", -- 监听地址 127.0.0.1
	port = 8888,
	maxclient = 1024,
	nodelay = true,
}

 skynet.start(function()
	local gateserver = skynet.newservice("gated")
	pcall(skynet.send, gateserver, "lua","start",gate_conf)

	skynet.exit()
end)

 
 
 