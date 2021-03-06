local skynet = require "skynet"
require "skynet.manager"

local gate
local CMD = {}
local SOCKET = {}
local agents = {}


local function close(fd)
	local a = agents[fd]
	agents[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		skynet.send(a, "lua", "kick")
	end
end

function SOCKET.open(fd, addr)
	skynet.error("New client from : ", fd, addr)
	skynet.send(gate, 'lua', 'accept', fd)

	--发送到对应玩家上面
	agents[fd] = skynet.newservice("agent")
	skynet.call(agents[fd], "lua", "start", { gate = gate, fd = fd, watchdog = skynet.self() })
end

function SOCKET.close(fd)
	skynet.error("---SOCKET.close---", fd)
	close(fd)
end

function SOCKET.error(fd, msg)
	skynet.error("socket error",fd, msg)
	close(fd)
end

function SOCKET.warning(fd, size)
	skynet.error("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
	skynet.error("msg:",msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	skynet.error("socket close", fd)
	close(fd)
end

--广播数据
function CMD.broadcast_info(msg_name, args)
	for fd, curent_agent in pairs(agents) do
		skynet.send(curent_agent, "lua", "broadcast_info", fd, msg_name, args)
	end
end

skynet.start(function()
	--解析
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	skynet.register("watchdog")
	gate = skynet.newservice("gate")
end)







