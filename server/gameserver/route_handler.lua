local skynet = require("skynet")

local Route = {
	index = 0,
}


function Route.RegisterReq(args)
	Route.index = (Route.index + 1)%10
	local db = skynet.call("redis","lua", "get_connet", Route.index)
	local db_data = db:hmget("login_db","login_db"..args.UserName)
end

return Route