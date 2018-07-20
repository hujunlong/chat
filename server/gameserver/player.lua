local skynet = require "skynet"
local socket = require "socket"
local json = require "cjson"
local filelog = require "filelog"
local md5 = require "md5"
local utility = require "utility"
require "msg"
require "enum"

local Head = Head
local EnterGameRes = EnterGameRes
local ChatListRes = ChatListRes
local ChatNtc = ChatNtc
local ChatRes = ChatRes

local EErrCode = EErrCode

local Player = {
	Rid  = 0,
	fd = 0,
	gate = 0,
	watchdog = 0,
}

local function send_2_client(fd, package_name, data)
	--记录日志
	filelog.sys_protomsg(package_name, data)
	
	Head.MessaegName = package_name
	local encode_head_msg = json.encode(Head)
	local encode_body_msg = json.encode(data)
	
	--2字节总长度 + 2字节包头 + 包头数据 + 包体
	local head_package = string.pack(">s2", encode_head_msg) 
	local total_package = string.pack(">s2", head_package .. encode_body_msg)
 
	socket.write(fd, total_package)
end

function Player.init(fd, gate, watchdog) 
	Player.fd = fd
	Player.gate = gate
	Player.watchdog = watchdog
end


function Player.EnterGameReq(args)
	if args.Rid == nil or args.Token == nil then
		EnterGameRes.Errcode = EErrCode.ERR_INVALID_REQUEST
		EnterGameRes.Errcodedes = "参数请求不全"
		send_2_client(Player.fd, "EnterGameRes", EnterGameRes)
		--断开连接
		skynet.send("watchdog", "lua", "socket", "close", Player.fd)
		return
	end

	if md5.sumhexa(tostring(args.Rid)) ~= utility.trim(args.Token) then
		EnterGameRes.Errcode = EErrCode.ERR_VERIFYTOKEN_FAILED
		EnterGameRes.Errcodedes = "token 验证失败"
		send_2_client(Player.fd, "EnterGameRes", EnterGameRes)
		--断开连接
		skynet.send("watchdog", "lua", "socket", "close", Player.fd)
		filelog.sys_error("---Player.EnterGameReq---", md5.sumhexa(tostring(args.Rid)) , args.Token)
		return
	end

	--登陆成功 TODO 加载玩家相关数据
	Player.Rid = args.Rid
	
	send_2_client(Player.fd, "EnterGameRes", EnterGameRes)
end

function Player.ChatListReq(args)
	local chat_info = skynet.call("chatservice", "lua", "GetChatList")
	ChatListRes.MsgList = chat_info
	send_2_client(Player.fd, "ChatListRes", ChatListRes)
end

function Player.broadcast_info(fd, msg_name, args)
	filelog.sys_info("---broadcast_info---", msg_name, args)
	if msg_name == "ChatNtc" then
		ChatNtc.Rid = args.Rid
		ChatNtc.Msg = args.Msg
		send_2_client(fd, msg_name, ChatNtc)
	end
end

function Player.ChatReq(args)
	args.Rid = Player.Rid
	skynet.send("chatservice", "lua", "chat", args)
	send_2_client(Player.fd, "ChatRes", ChatRes)--默认值
	
	--广播所以人
	skynet.send(Player.watchdog, "lua", "broadcast_info", "ChatNtc", args)
end



return Player