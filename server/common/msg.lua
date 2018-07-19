Head = {
	MsgType = 0,
	MessaegName = "",
}

RegisterReq = {
	UserName = "",
	Pwd = "",
}

RegisterResult = {
	Errcode = 0,
	Errcodedes = "",
}

LoginReq = {
	UserName = "",
	Pwd = "",
}

LoginResult = {
	Errcode = 0,
	Errcodedes = "",
	Rid = 0,--注册的rid
	Token = "",
	Ip = "192.168.0.38",
	Port=8888,
}

------------------------
EnterGameReq = {
	Rid = 0,
	Token = "",
}

EnterGameRes = {
	Errcode = 0,
	Errcodedes = "",
}

--聊天列表
ChatListReq = {
	Rid = 0,
}

ChatListRes = {
	Errcode = 0,
	Errcodedes = "",
	MsgList = {},
}

--聊天
ChatReq = {
	Msg = "",
}

ChatRes = {
	Errcode = 0,
	Errcodedes = "",
	 
}

ChatNtc = {
	Rid = 0,
	UserName = "",
	Msg = "",
}

