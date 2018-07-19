local skynet = require "skynet"
local json = require "cjson"
local filelog = require "filelog"
local PlayerdataDAO = {}

function PlayerdataDAO.query_player_register(name)
	local rid = math.random(1,20)
	local requestmsg = {
		rid = rid,
		rediscmd = "hget",
		rediskey = "register:"..name,
		rediscmdopt1 = "info",
	}

	filelog.sys_info("-----query_player_register-----1")
	local result, data = skynet.call(".dbmanagerservice", "lua", "query", requestmsg)
	filelog.sys_info("-----query_player_register-----2")
	if data ~= nil then
		return result, json.decode(data)
	end
	return result, nil
end


function PlayerdataDAO.get_new_rid()
	local rid = math.random(1,20)
	local requestmsg = {
		rid = rid,
		rediscmd = "incr",
		rediskey = "rid_max",
	}

	local _, rid_max = skynet.call(".dbmanagerservice", "lua", "query", requestmsg)
	return rid_max
end


function PlayerdataDAO.save_new_player_register(info)
	local rid = math.random(1,20)
	local noticemsg = {
		rid = rid,
		rediscmd = "hset",
		rediskey = "register:"..info.UserName,
		rediscmdopt1 = "info",
		rediscmdopt2 = json.encode(info),
	}

	skynet.send(".dbmanagerservice", "lua", "update", noticemsg)
end

return PlayerdataDAO