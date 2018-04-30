local skynet = require "skynet"
local socket = require "socket"
local json = require "cjson"
local player = require "player"

local Agent = {
	gate = 0,
	fd = 0,
	watchdog = 0,
}

function Agent.start(conf)
	Agent.fd = conf.fd
	Agent.gate = conf.gate
	Agent.watchdog = conf.watchdog

	skynet.error("Agent.fd, skynet.self()", Agent.fd, skynet.self())
	player.init(Agent.fd, Agent.gate, Agent.watchdog) --初始化

	skynet.call(Agent.gate, "lua", "forward", Agent.fd)
end

function Agent.kick()
	skynet.exit()
end

--int16总长度(不含总长度自己的2字节长度) + int16(包头长度) + (包头数据) + (具体数据)
function unpack_client_message( ... )
	local msgbuf, msgsize = ...
	skynet.error("msgbuf", msgbuf, "msgsize",msgsize)
	 
	if msgsize <= 2 then
		skynet.error("ServerBase:decode_client_message invalid msgsize", msgsize)
		return nil, nil		
	end
	
	msgbuf = skynet.tostring(msgbuf, msgsize)	

	local msgheadsize = msgbuf:byte(1) * 2^8 + msgbuf:byte(2)

	local msghead, msgbody = msgbuf:sub(3,2+msgheadsize), msgbuf:sub(3+msgheadsize)

	return msghead, msgbody
end

function process_client_message(session, source, ...)
	local msghead, msgbody = ... 
	skynet.error("msghead, msgbody:",msghead, msgbody)
	
	local head = json.decode(msghead)
	
	local f = player[head.MessaegName]
	if f == nil then
		skynet.error("head.MessaegName:%s not found",head.MessaegName)
		return
	end

	f(json.decode(msgbody))
end

--注册解析消息
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack =  unpack_client_message,
	dispatch = process_client_message,
}

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = Agent[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
