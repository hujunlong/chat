local skynet = require "skynet"
local cluster = require "cluster"
--local parser = require "parser"
function deal_cluster()
	cluster.open "db"
end

function deal_pb()
	parser.register("clientmsg.proto" ,"./")

	local addressbook1 = {
		name = "Alice",
		id = 12345,
		phone = {
			{ number = "1301234567" },
			{ number = "87654321", type = "WORK" },
			{ number = "13912345678", type = "MOBILE" },
		},
		email = "username@domain.com"
	}

	local code1 = protobuf.encode("tutorial.Person", addressbook1)
	local code2 = protobuf.decode("tutorial.Person", code1)
	skynet.error("code2:",code2.name)
end


local gate_conf = {
	address = "127.0.0.1", -- 监听地址 127.0.0.1
	port = 8888,
	maxclient = 1024,
	nodelay = true,
}

 skynet.start(function()

 	--deal_pb()

 	--redis
	--local redis = skynet.newservice("redis")
	--pcall(skynet.send,redis,"lua","connet")

	--网关服务器
	local gateserver = skynet.newservice("gated")
	pcall(skynet.send, gateserver, "lua","start",gate_conf)

	skynet.exit()
end)

 
 
 