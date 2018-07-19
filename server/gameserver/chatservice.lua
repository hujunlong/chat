local skynet = require "skynet"
local filelog = require "filelog"
require "skynet.manager"

local CMD = {
	chat_list = {} --聊天列表
}
 
function CMD.GetChatList()
	filelog.sys_info("---GetChatList---", CMD.chat_list)
	return CMD.chat_list
end

function CMD.chat(chat_info) --fd,rid,chat_name,msg
	filelog.sys_info("---chat---", chat_info.Rid, chat_info.Msg)
	if #CMD.chat_list >= 5 then
		table.remove(CMD.chat_list, 1)
	end
	table.insert(CMD.chat_list,{Rid = chat_info.Rid, Msg = chat_info.Msg})
end

skynet.start(function()
	skynet.register("chatservice")

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(...)))
	end)
end)

 