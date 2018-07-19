local skynet = require "skynet"
local redis = require "redis"
require "skynet.manager"
local filelog = require "filelog"

local db_connect 
local CMD = {
}

function CMD.connet(conf)
	if db_connect ~= nil then
  		setmetatable(CMD, nil)
  		CMD.__index = nil
  		db_connect:disconnect()
  		db_connect = nil
  	end 

	db_connect = redis.connect{
		host = conf.host,
		port = conf.port,
		db = conf.db,
	}

	local dbmeta = getmetatable(db_connect)
	setmetatable(CMD, dbmeta)
	CMD.__index = dbmeta
end

function CMD.exit()
	setmetatable(CMD, nil)
	CMD.__index = nil
	db_connect:disconnect()
	db_connect = nil
	skynet.exit()
end 

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
	
		local f = assert(CMD[cmd])
		if cmd == "connet" then
			skynet.retpack(f(...))
            return
		end

		filelog.sys_db_info("redis cmd:", cmd, ...)
		local result, result_data = pcall(f, db_connect, ...)

		if not result then
			filelog.stack_traceback("db error:", "result", result, "result_data",result_data, "input:", cmd, ...)
		end

		pcall(skynet.retpack, result, result_data)
	end)
end)