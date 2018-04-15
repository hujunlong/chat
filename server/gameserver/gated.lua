local skynet = require "skynet"
local timetool = require "timetool" 
local gate
local CMD = {}
local SOCKET = {}
local agents = {}

local function close_agent(fd)
	skynet.error("--close_agent---",fd)
	skynet.send(agents[fd], "lua", "close_agent",fd)
	agents[fd] = nil
end

function SOCKET.open(fd, addr)
	-- agents[fd] = {
	-- 	agent = skynet.newservice("agent"),
	-- 	time = timetool.get_time(),
	-- }
	-- skynet.send(agents[fd].agent, "lua", "open_agent",fd, addr)
	skynet.error("New client from : ", fd, addr)
	skynet.send(gate, 'lua', 'accept', fd)
end

function SOCKET.close(fd)
	skynet.error("---SOCKET.close---", fd)
	skynet.call(gate, "lua", "kick", fd)
end

function SOCKET.error(fd, msg)
	skynet.error("socket error",fd, msg)
	skynet.call(gate, "lua", "kick", fd)
end

function SOCKET.warning(fd, size)
	skynet.error("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
	skynet.error("---SOCKET.data---", fd, "msg:",msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

function check_alive()
	while true do
		skynet.sleep(400)
		now_time = timetool.get_time()
	end
end

skynet.start(function()

	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("wsgate")
end)







