Head = {
	MsgType = 0,
	MessaegName = "",
}

RegisterReq = {
	UserName = "",
	Pwd = "",
}

RegisterResult = {
	Status = 0,--0:ok 1:已经存在相同名字
}

LoginReq = {
	UserName = "",
	Pwd = "",
}
LoginResult = {
	Status = 0,--0:ok 1:用户名与密码不匹配 2:该账户未注册
	Rid = 0,--注册的rid
}

------------------------
EnterGameReq = {
	Rid = 0,
}

EnterGameRes = {
	Status = 0,--0:ok 1:账号服务器未通知
}

--聊天列表
ChatListReq = {
	Rid = 0,
}

ChatListRes = {
	MsgList = {},
}

--聊天
ChatReq = {
	Rid = 0,
	Msg = "",
}

ChatRes = {
	Status = 0, --成功
}

ChatNtc = {
	rid = 0,
	UserName = "",
	Msg = "",
}

