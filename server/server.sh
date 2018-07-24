#!/bin/bash

PATH="$(dirname $0)/common/lbf/lbf:$PATH"
echo "$(dirname $0)/common/lbf/lbf"
source lbf_init.sh

export var_project_path=$(cd `dirname $0`; pwd)
export var_mod_file="${var_project_path}/mod.txt"
export var_max_try=3
export var_skynet="../../lib/skynet/skynet"

function usage 
{
  echo "Usage: $(path::basename $0) [start|stop|restart] ...]"
}

function main
{
	case $1 in 
    start)      shift; do_start         ${@};;
    stop)       shift; do_stop          ${@};;
    restart)    shift; do_restart       ${@};;
    *)          usage;;
  esac  
}
 
function do_start
{
  case $1 in
    all) 
      cat ${var_mod_file} | while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
        server::start ${svrid}
      done ;;

    *)
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      server::start $svrid;;
  esac
}


function do_stop
{
  util::is_empty $1 && usage && return 1

  case $1 in
    all) 
      cat ${var_mod_file} | while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
        server::stop ${svrid}
      done ;;

    *)
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      server::stop ${svrid};;
  esac
}


function do_restart 
{
  util::is_empty $1 && usage && return 1

  case $1 in
    all) 
      cat ${var_mod_file} | while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
        server::restart ${svrid}
      done ;;

    *) 
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      server::restart ${svrid};;
  esac
}


function server::is_alive 
{
  io::no_output pgrep -u `whoami` -xf "${*}" && return 0 || return 1
}


function server::start 
{

  local _dir="${var_project_path}/$(basename ${1})/" && cd $_dir
  ulimit -c unlimited
  sudo sysctl -w kernel.shmmax=4000000000

  for ((_cnt = 1; _cnt < ${var_max_try}; _cnt++)); do
      server::is_alive "$var_skynet config_${@}" && break
      eval "$var_skynet config_${@}"
      sleep 0.5
  done

  #sleep 1秒方便打印消息
  sleep 0.5

  if [ -f "${_dir}systemlog" ]; then
     tail -25 "${_dir}systemlog"
  fi

  if [ ! $_cnt -eq ${var_max_try} ]; then
    io::green "[$@] start succeed\r\n"
    return 0
  else
    io::red "[$@] start failed\r\n"
    return 1
  fi
}


function server::stop 
{
  
  server::is_alive "$var_skynet config_${@}" && pkill -u `whoami` -xf "$var_skynet config_${@}"

  for ((_cnt = 1; _cnt < ${var_max_try}; _cnt++)); do
    sleep 0.1
    ! server::is_alive "$var_skynet config_${@}" && break
  done

  if [ ! $_cnt -eq ${var_max_try} ]; then 
    io::green "[$@] stop succeed\r\n"
    return 0
  else
    io::red "[$@] stop failed\r\n"
    return 1
  fi
}


function server::restart
{
  ! server::stop ${@} && return 1
  ! server::start ${@} && return 1
}

#运行主程序
main "${@}"


