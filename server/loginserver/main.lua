local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function()

	local proxy = cluster.proxy("db","redis")
	skynet.send(proxy,"lua","save_player",1,{aa="12"})

	--[[
	local loginserver = skynet.newservice("logind")
	local gate = skynet.newservice("gated", loginserver)

	skynet.call(gate, "lua", "open" , {
		port = 8888,
		maxclient = 64,
		servername = "sample",
	})
	--]]
end)
