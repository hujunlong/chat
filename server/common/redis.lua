local skynet = require "skynet"
local redis = require "redis"
local json = require "cjson"
require "skynet.manager"

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0,
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

function CMD.save_data_by_rid(rid, data)
	skynet.error("-----query_player------",rid,data)
	local db = CMD.get_connet(rid)
	db:set('Rid:' .. rid,data)
end

function CMD.query_data_by_rid(rid)
	skynet.error("-----query_player------",rid,data)
	local db = CMD.get_connet(rid)
	db:get('Rid:'..rid,data)
end

function CMD.save_data_by_username(username, data)
	data.Rid = CMD.get_new_rid()
	skynet.error("-----save_data_by_username------", username, json.encode(data))
	local db = CMD.get_connet(data.Rid)
	db:set("UserName:"..username, json.encode(data) )
end

function CMD.query_data_by_username(username)
	local rid = 1
	skynet.error("-----query_data_by_username------",username)
	local db = CMD.get_connet(rid)
    local data = db:get("UserName:"..username)
    if data == nil then
    	return data
    end

    return json.decode(data)
end

function CMD.get_new_rid()
	local rid = 1
	skynet.error("----get_new_rid---")
	local db = CMD.get_connet(rid)
	return db:incr("rid_max")
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)