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

GetChatListReq = {
	Rid = 0,
}

GetChatListRes = {
	MsgList = {},
}