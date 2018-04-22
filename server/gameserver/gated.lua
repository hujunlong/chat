local skynet = require "skynet"
local timetool = require "timetool" 
local json = require "cjson"
local sproto = require "sproto"


local gate
local CMD = {}
local SOCKET = {}
local agents = {}


function close(fd)

	local a = agents[fd]
	agents[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
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
	local msg_data = json.decode(msg)
	skynet.error("msg:",msg_data.Name, msg_data.Age)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	skynet.error("socket close", fd)
	close(fd)
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

	gate = skynet.newservice("gate")
end)







