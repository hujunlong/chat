local skynet = require "skynet"
require "skynet.manager"
local command = {}

local cluster_info = {}

function command.login(args)
	skynet.error("---command.login---",args.UserName, args.Rid)
	local rid = args.Rid 
	cluster_info[rid] = args
	--todo 记录登录时间
end

function command.get_notice_info_by_login(rid)
	return cluster_info[rid]
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		skynet.error(" --- cluster_game cmd --- ",cmd)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "cluster_game"
end)