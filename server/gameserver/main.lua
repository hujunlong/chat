local skynet = require "skynet"
local cluster = require "cluster"


function deal_cluster()
	skynet.newservice("cluster_game")
	cluster.open "cluster_game_1"
end

local gate_conf = {
	address = "127.0.0.1", -- 监听地址 127.0.0.1
	port = 8888,
	maxclient = 1024,
	nodelay = true,
}

 skynet.start(function()
 	--开启进程间通信
 	deal_cluster()
	local gateserver = skynet.newservice("gated")
	pcall(skynet.send, gateserver, "lua","start",gate_conf)

	skynet.exit()
end)

 
 
 