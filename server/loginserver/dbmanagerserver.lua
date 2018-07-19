local skynet = require "skynet"
require "skynet.manager"

local DbManager = {
	pool = {},
	db_connet_num = 0,
}

function DbManager.start(conf)
	DbManager.db_connet_num = tonumber(skynet.getenv("db_connet_num"))
	for i=0,DbManager.db_connet_num do
		local redis_server = skynet.newservice("redis")
		pcall(skynet.send, redis_server, "lua", "connet", conf)
		table.insert(DbManager.pool, redis_server)
	end
end

--请求方式
-- local noticemsg = {
-- 		rid = rid,
-- 		rediscmd = "hset",
-- 		rediskey = "roleinfo:"..rid,
-- 		rediscmdopt1 = "info",
-- 		rediscmdopt2 = json.encode(info),
-- }		
function DbManager.query(requestmsg)
	local rid = requestmsg.rid or 1
	local db_connet_num = DbManager.db_connet_num or 20
	local cmd = requestmsg.rediscmd
	local rediskey = requestmsg.rediskey
	local rediscmdopt1 = requestmsg.rediscmdopt1
	local rediscmdopt2 = requestmsg.rediscmdopt2

	local redis_server = DbManager.pool[rid%db_connet_num]
	if rediscmdopt2 ~= nil then
		local _, result, data = pcall(skynet.call, redis_server, "lua", cmd, rediskey, rediscmdopt1, rediscmdopt2)
		return result, data
	else
		local _, result, data = pcall(skynet.call, redis_server, "lua", cmd, rediskey, rediscmdopt1)
		return result, data
	end
end

 
--按照下面格式
-- local requestmsg = {
-- 	rid = 12,
-- 	rediscmd = "hget",
-- 	rediskey = "roleinfo:"..12,
-- 	rediscmdopt1 = "info",
-- }

function DbManager.update(noticemsg)
	local rid = noticemsg.rid or 1
	local db_connet_num = DbManager.db_connet_num or 20
	local cmd = noticemsg.rediscmd
	local rediskey = noticemsg.rediskey
	local rediscmdopt1 = noticemsg.rediscmdopt1
	local rediscmdopt2 = noticemsg.rediscmdopt2

	local redis_server = DbManager.pool[rid%db_connet_num]
	
	return pcall(skynet.send, redis_server, "lua", cmd, rediskey, rediscmdopt1, rediscmdopt2)
end


skynet.start(function()
	--解析
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(DbManager[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register(SERVICE_NAME)
end)




