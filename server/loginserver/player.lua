local skynet = require "skynet"
local socket = require "socket"
local json = require "cjson"
local playerdatadao = require "playerdatadao"
local md5 = require "md5"
local filelog = require "filelog"
require "msg"

local Head = Head
local RegisterResult = RegisterResult
local LoginResult = LoginResult

local Player = {
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

function Player.RegisterReq(fd, args)
	local _, data = playerdatadao.query_player_registe(args.UserName)
	if data == nil then
		args.Rid = playerdatadao.get_new_rid()
		playerdatadao.save_new_player_register(args)
		RegisterResult.Status = 0
	else
		RegisterResult.Status = 1	 
	end
	
	send_2_client(fd, "RegisterResult", RegisterResult)
end

function Player.LoginReq(fd, args)
	local status, data = playerdatadao.query_player_register(args.UserName)
	if status and data then
		if (data.UserName == args.UserName) and (data.Pwd == args.Pwd) then
			LoginResult.Status = 0
			LoginResult.Rid = data.Rid
			LoginResult.Token = md5.sumhexa(tostring(data.Rid))
			filelog.sys_info("---LoginReq---", data.Rid, data.UserName, data.Pwd, LoginResult.Token)

			--断开连接
			skynet.send("watchdog", "lua", "socket", "close", fd)
		else
			LoginResult.status = 1
		end
	else
		LoginResult.status = 2	
	end
	
	send_2_client(fd, "LoginResult", RegisterResult)
end

return Player