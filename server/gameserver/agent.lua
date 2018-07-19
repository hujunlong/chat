local skynet = require "skynet"
local json = require "cjson"
local player = require "player"
local filelog = require "filelog"

local Agent = {
	gate = 0,
	fd = 0,
	watchdog = 0,
}

function Agent.start(conf)
	Agent.fd = conf.fd
	Agent.gate = conf.gate
	Agent.watchdog = conf.watchdog

	filelog.sys_info("Agent.fd, skynet.self()", Agent.fd, skynet.self())

	player.init(Agent.fd, Agent.gate, Agent.watchdog) --初始化

	skynet.call(Agent.gate, "lua", "forward", Agent.fd)
end

function Agent.kick()
	skynet.exit()
end

function Agent.broadcast_info(fd, msg_name, args)
	local f = player["broadcast_info"]
	if f == nil then
		filelog.sys_error("broadcast_info head.MessaegName:%s not found",fd, msg_name,args)
		return
	end

	local status, data = pcall(f, fd, msg_name, args)
	if not status then
		filelog.stack_traceback("input:", msg_name, args, "err msg:", data)
	end
end

--int16总长度(不含总长度自己的2字节长度) + int16(包头长度) + (包头数据) + (具体数据)
local function unpack_client_message( ... )
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

local function process_client_message(session, source, ...)
	local msghead, msgbody = ... 
	local head = json.decode(msghead)
	
	local f = player[head.MessaegName]
	if f == nil then
		filelog.sys_error("head.MessaegName not found:",head.MessaegName)
		return
	end

	--记录消息日志
	filelog.sys_protomsg(head.MessaegName, json.decode(msgbody))
	local status, data = pcall(f, json.decode(msgbody))
	if not status then
		filelog.stack_traceback("input:", head.MessaegName, json.decode(msgbody), "err msg:", data)
	end
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
		if f == nil then
			filelog.sys_error("agent:", command, ...)
		end 
		skynet.ret(skynet.pack(f(...)))
	end)
end)
