local skynet = require "skynet"
require "skynet.manager"
local command = {}

function command.login(args)
	skynet.error("---command.login---",args.UserName)
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