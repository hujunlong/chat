local skynet = require "skynet"

local FileLog = {}

local SERVICE_NAME = SERVICE_NAME

function FileLog.sys_info(...)
    if not skynet.getenv("info") == "false" then
        return
    end
	skynet.send(".loggerserver", "lua", "info", "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end


function FileLog.sys_warning(...)
    if skynet.getenv("warning") == "false" then
        return
    end

    skynet.send(".loggerserver", "lua", "warning", "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end


function FileLog.sys_error(...)
    if not skynet.getenv("error") == "false" then
        return
    end
	skynet.send(".loggerserver", "lua", "error", "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end

function FileLog.sys_db_info(...)
    if not skynet.getenv("info") == "false" then
        return
    end
    skynet.send(".loggerserver", "lua", "db_info", "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end


function FileLog.sys_protomsg(msgname,...)
    if skynet.getenv("protomsg") == "false" then
        return
    end    

    if msgname == nil or type(msgname) ~= "string" then
        return
    end

    skynet.send(".loggerserver", "lua", "protomsg", msgname, "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end


function FileLog.stack_traceback(...)
    skynet.send(".loggerserver", "lua", "stack_traceback", "servicename:"..SERVICE_NAME.." service_id:"..skynet.self(), ...)
end

return FileLog