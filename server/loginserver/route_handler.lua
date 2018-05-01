local skynet = require "skynet"
local socket = require "socket"
local json = require "cjson"
local msg = require "msg"
local cluster = require "cluster"

local Route = {
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

function Route.RegisterReq(fd, args)
	local data = skynet.call("redis","lua", "query_data_by_username", args.UserName)
	if data == nil then
		skynet.send("redis","lua", "save_data_by_username", args.UserName, args)
		RegisterResult.status = 0
		skynet.error("status:",RegisterResult.status)
	else
		RegisterResult.status = 1
		skynet.error("status:",RegisterResult.status)
	end
	
	send_2_client(fd, "RegisterResult", RegisterResult)
end

function Route.LoginReq(fd, args)
	local data = skynet.call("redis","lua", "query_data_by_username", args.UserName)
	if data ~= nil then
		if (data.UserName == args.UserName) and (data.Pwd == args.Pwd) then
			LoginResult.status = 0
			LoginResult.Rid = data.Rid

			skynet.error("---LoginReq---", data.Rid, data.UserName, data.Pwd)
			--通知gate服务器
			local proxy = cluster.proxy("cluster_game_1", "cluster_game")
			skynet.send(proxy, "lua", "login", data)

			--todo 需要断开处理
		else
			LoginResult.status = 1
		end
	else
		LoginResult.status = 2	 
	end
	
	send_2_client(fd, "LoginResult", RegisterResult)
end

return Route