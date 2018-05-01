local skynet = require "skynet"
local socket = require "socket"
local json = require "cjson"
local msg = require "msg"

local Player = {
	Rid  = 0,
	fd = 0,
	gate = 0,
	watchdog = 0,
}

function send_2_client(fd, package_name, data)
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
	local login_info = skynet.call("cluster_game", "lua", "get_notice_info_by_login", args.Rid)
	if login_info == nil then
		EnterGameRes.Status = 1 
	else
		EnterGameRes.Status = 0
		Player.Rid = login_info.Rid
	end

	send_2_client(Player.fd, "EnterGameRes", EnterGameRes)
end

function Player.ChatListReq(args)
	--验证是否已经登录成功
	local chat_info = skynet.call("chat", "lua", "GetChatList")
	ChatListRes.MsgList = chat_info
	send_2_client(Player.fd, "ChatListRes", ChatListRes)
end

function Player.BroadCastNtc(fd, msg_name, args)
	skynet.error("---BroadCastNtc---", msg_name, args)
	if msg_name == "ChatNtc" then
		ChatNtc.Rid = args.Rid
		ChatNtc.Msg = args.Msg
		send_2_client(fd, msg_name, ChatNtc)
	end
end

function Player.ChatReq(args)
	skynet.send("chat", "lua", "chat",args)
	send_2_client(Player.fd, "ChatRes", ChatRes)--默认值
	
	--广播所以人
	skynet.send(Player.watchdog, "lua", "broadcast_info", "ChatNtc", args)
end



return Player