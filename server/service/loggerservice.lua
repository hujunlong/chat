local skynet = require "skynet"
local utility = require "utility"
require "skynet.manager"


local CMD = {}

local function get_file_name(dirname, filename)
     ----- 日志分日期存储------
    local path = skynet.getenv("logpath")
    if path == nil then
        path = "."
    end
    
    if dirname == nil then
        dirname = "."
    end

    local current_time = os.date("%Y_%m_%d", math.floor(skynet.time()))
    local log_path = path.."/"..current_time.."/"..dirname
    local current_file_name = log_path.."/"..filename
    if not utility.is_file_exist(log_path) then
        os.execute("mkdir -p "..log_path)
    end
    return current_file_name
end


local function write_log(file, ...)
    local f = io.open(file, "a+")
    if f ~= nil then
        f:write("-------------["..os.date("%Y-%m-%d %X", math.floor(skynet.time())).."]--------------\n")
        local arg = table.pack(...)
        if arg ~= nil then
            for key, value in pairs(arg) do
                if key ~= "n" then
                    if type(value) ~= "table" then
                        f:write(tostring(value).."\n")                
                    else
                        local str = utility.dump(value)  
                        f:write(str.."\n")                
                    end
                end 
            end
        end
        f:close()
    end 
end


local function write_protomsg_log(file, msgname, ...)
    local f = io.open(file, "a+")
    if f ~= nil then
        f:write("["..os.date("%Y-%m-%d %X", math.floor(skynet.time())).."] msgname: "..msgname.."\n")
        local arg = table.pack(...)
        if arg ~= nil then
            for key, value in pairs(arg) do
                if key ~= "n" then
                    if type(value) ~= "table" then
                        f:write(tostring(value).."\n")                
                    else
                        local str = utility.dump(value) 
                        f:write(str.."\n")                
                    end
                end 
            end
        end
        f:close()
    end     
end


function CMD.error(...)
   local file = get_file_name(".", "error.log")
   write_log(file, ...)
end

function CMD.stack_traceback(...)
   local file = get_file_name(".", "traceback.log")
   write_log(file, ...)
end

function CMD.info(...)
    local file = get_file_name(".", "info.log")
    write_log(file, ...)
end

function CMD.warning(...)
    local file = get_file_name(".", "warning.log")
    write_log(file, ...)
end

function CMD.protomsg(msgname, ...)
    local file = get_file_name(".", "protomsg.log")
    write_protomsg_log(file, msgname, ...)
end

function CMD.db_info(...)
    local file = get_file_name(".", "db_info.log")
    write_log(file, ...)
end

skynet.start(function()
	skynet.register(".loggerservice")

    skynet.dispatch("lua", function(_,_, command, ...)
      
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
end)