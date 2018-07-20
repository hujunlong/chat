package main

import (
	// "bufio"
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"time"
	//"golang.org/x/net/websocket"
	"bufio"
	//"crypto/md5"
	"io"
	"os"
	"strconv"
	"strings"
)

type Head struct {
	MsgType     int32
	MessaegName string
}

type RegisterReq struct {
	UserName string
	Pwd      string
}

type RegisterResult struct {
	Errcode    int32
	Errcodedes string
}

type LoginReq struct {
	UserName string
	Pwd      string
}

type LoginResult struct {
	Errcode    int32
	Errcodedes string
	Rid        int32
	Token      string
	Ip         string
	Port       int32
}

type EnterGameReq struct {
	Rid   int32
	Token string
}

type EnterGameRes struct {
	Errcode    int32
	Errcodedes string
}

type ChatListReq struct {
	Rid int32
}

type Chat struct {
	Rid int32
	Msg string
}
type ChatListRes struct {
	Errcode    int32
	Errcodedes string
	MsgList    [5]Chat
}

type ChatReq struct {
	Msg string
}

type ChatRes struct {
	Errcode    int32
	Errcodedes string
}

type ChatNtc struct {
	Rid      int32
	UserName string
	Msg      string
}

//字符串转int32
func Str2int32(str string) int32 {
	str = strings.TrimSpace(str)
	data_int, error := strconv.Atoi(str)
	if error != nil {
		return 0
	}
	return int32(data_int)
}

func package_msg(msg_name string, v interface{}) []byte {
	var total_msg []byte

	//包头消息
	head := new(Head)
	head.MsgType = 1
	head.MessaegName = msg_name

	//包头二进制组
	head_buf_byte := bytes.NewBuffer([]byte{})
	head_data, _ := json.Marshal(head)
	head_len := int16(len(head_data))
	binary.Write(head_buf_byte, binary.BigEndian, &head_len)
	total_msg = append(head_buf_byte.Bytes(), head_data...)

	//数据内容
	body_data, _ := json.Marshal(v)
	total_msg = append(total_msg, body_data...)

	//添加总长度
	len_32 := int16(2) + head_len + int16(len(body_data))
	len_buf := bytes.NewBuffer([]byte{})
	binary.Write(len_buf, binary.BigEndian, &len_32)

	total_msg = append(len_buf.Bytes(), total_msg...)

	fmt.Println("msg:", total_msg)
	return total_msg
}

func readFully(conn net.Conn) {
	var buf [512]byte

	for {
		len_, err := conn.Read(buf[0:])

		if err != nil {
			if err == io.EOF {
				break
			}
		}

		if len(buf) < 4 {
			return
		}

		var total_len int16 = 0
		var head_len int16 = 0
		buffer_total_len := bytes.NewBuffer(buf[0:2])
		buffer_head_len := bytes.NewBuffer(buf[2:4])
		binary.Read(buffer_total_len, binary.BigEndian, &total_len)
		binary.Read(buffer_head_len, binary.BigEndian, &head_len)

		fmt.Println("total_len:", total_len, "head_len:", head_len)

		head := new(Head)
		fmt.Println("rev buf:", buf[0:len_])
		json.Unmarshal(buf[4:4+head_len], head)

		if head.MessaegName == "RegisterResult" {
			register_result := new(RegisterResult)
			json.Unmarshal(buf[4+head_len:total_len+2], register_result) //+2因为总长度未算
			fmt.Println("register_result:", register_result)
		}

		if head.MessaegName == "LoginResult" {
			login_result := new(LoginResult)
			json.Unmarshal(buf[4+head_len:total_len+2], login_result) //+2因为总长度未算
			fmt.Println("LoginResult:", login_result)
		}

	}
}

func readFully2(conn net.Conn) {
	var buf [512]byte

	for {
		len_, err := conn.Read(buf[0:])

		if err != nil {
			if err == io.EOF {
				break
			}
		}

		if len(buf) < 4 {
			return
		}

		var total_len int16 = 0
		var head_len int16 = 0
		buffer_total_len := bytes.NewBuffer(buf[0:2])
		buffer_head_len := bytes.NewBuffer(buf[2:4])
		binary.Read(buffer_total_len, binary.BigEndian, &total_len)
		binary.Read(buffer_head_len, binary.BigEndian, &head_len)

		fmt.Println("total_len:", total_len, "head_len:", head_len)

		head := new(Head)
		fmt.Println("rev buf:", buf[0:len_])
		json.Unmarshal(buf[4:4+head_len], head)

		if head.MessaegName == "EnterGameRes" {
			register_result := new(EnterGameRes)
			json.Unmarshal(buf[4+head_len:total_len+2], register_result) //+2因为总长度未算
			fmt.Println("EnterGameRes:", register_result)
		}

		if head.MessaegName == "ChatListRes" {
			register_result := new(ChatListRes)
			json.Unmarshal(buf[4+head_len:total_len+2], register_result) //+2因为总长度未算
			fmt.Println("ChatListRes:", register_result)
		}

		if head.MessaegName == "ChatRes" {
			register_result := new(ChatRes)
			json.Unmarshal(buf[4+head_len:total_len+2], register_result) //+2因为总长度未算
			fmt.Println("ChatRes:", register_result)
		}

		if head.MessaegName == "ChatNtc" {
			register_result := new(ChatNtc)
			json.Unmarshal(buf[4+head_len:total_len+2], register_result) //+2因为总长度未算
			fmt.Println("ChatNtc:", register_result)
		}

	}
}

func main() {
	fmt.Println("start ...")

	//登录服
	conn_login, err := net.Dial("tcp", "192.168.0.38:8887")
	if err != nil {
		log.Fatal(err)
	}
	defer conn_login.Close()
	go readFully(conn_login)

	//游戏服
	conn_game, err2 := net.Dial("tcp", "192.168.0.38:8888")
	if err2 != nil {
		log.Fatal(err2)
	}
	defer conn_game.Close()
	go readFully2(conn_game)

	inputReader := bufio.NewReader(os.Stdin)
	for {
		cmd, _ := inputReader.ReadString('\n')
		cmd = strings.TrimSpace(cmd)

		cmd_id := Str2int32(cmd)
		switch cmd_id {
		//注册
		case 1:
			fmt.Println("输入用户名密码")
			cmd, _ = inputReader.ReadString('\n')
			strs := strings.Split(cmd, " ")
			UserName := strs[0]
			Pwd := strs[1]

			p := new(RegisterReq)
			p.UserName = UserName
			p.Pwd = Pwd
			buf := package_msg("RegisterReq", p)
			conn_login.Write(buf)
		//登录
		case 2:
			fmt.Println("输入用户名密码")
			cmd, _ = inputReader.ReadString('\n')
			strs := strings.Split(cmd, " ")
			UserName := strs[0]
			Pwd := strs[1]

			p := new(LoginReq)
			p.UserName = UserName
			p.Pwd = Pwd
			buf := package_msg("LoginReq", p)
			conn_login.Write(buf)
		//进入游戏服
		case 3:
			fmt.Println("输入rid与token")
			cmd, _ = inputReader.ReadString('\n')
			strs := strings.Split(cmd, " ")
			Rid := Str2int32(strs[0])
			Token := strs[1]

			p := new(EnterGameReq)
			p.Rid = Rid
			p.Token = Token
			buf := package_msg("EnterGameReq", p)
			conn_game.Write(buf)
		//获取聊天列表
		case 4:
			p := new(ChatListReq)
			buf := package_msg("ChatListReq", p)
			conn_game.Write(buf)
		//发言
		case 5:
			fmt.Println("输入内容msg")
			cmd, _ = inputReader.ReadString('\n')
			strs := strings.Split(cmd, " ")
			Msg := strs[0]

			p := new(ChatReq)
			p.Msg = Msg
			buf := package_msg("ChatReq", p)
			conn_game.Write(buf)
		}
	}

	time.Sleep(1000 * time.Minute)
}
