local skynet = require "skynet"
local redis = require "redis"
require "skynet.manager"

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local pool = {}
local db_connet_num = tonumber(skynet.getenv("db_connet_num")) 
local CMD = {}

function CMD.get_connet(rid)
	assert(rid)
	return pool[rid%db_connet_num]
end

function CMD.connet()
	local db = redis.connect{
		host = conf.host,
		port = conf.port,
		db = conf.db,
	}

	for i=1,db_connet_num do
		table.insert(pool, db)
	end
end

function CMD.save_player(rid, data)
	skynet.error("-----query_player------",rid,data)
	local db = CMD.get_connet(rid)
	db:set(rid,data)
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)