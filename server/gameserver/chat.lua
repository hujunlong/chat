local skynet = require "skynet"
require "skynet.manager"
local CMD = {}

local chat_list = {} --聊天列表
local agents = {} 

function CMD.GetChatList()
	skynet.error("---GetChatList---")
	return chat_list
end

function CMD.chat(chat_info) --fd,rid,chat_name,msg
	skynet.error("---chat---",chat_info.Rid, chat_info.Msg)
	if #chat_list >= 5 then
		table.remove(chat_list,1)
	end
	table.insert(chat_list,{Rid = chat_info.Rid, Msg = chat_info.Msg})
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register("chat")
end)

 