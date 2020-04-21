#!/bin/bash
function mimvp_app_rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000))
    echo $(($num%$max+$min))
}
cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
	if [[ $(command -v yum) ]]; then
		cmd="yum"
	fi
else
	echo -e "仅支持 Ubuntu / Debian / Centos" && exit 1
fi
$cmd update -y
if [[ $cmd == "yum" ]]; then
  $cmd install -y epel-release
  $cmd install -y python-pip net-tools
  $cmd install -y libsodium
else
  $cmd install -y python-pip net-tools libsodium-dev
fi
clear
echo "Start Install Shadowsocks"
pip install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf && sysctl -p

rndport=$(mimvp_app_rand 1024 65535)
rndpassword=$(date +%s%N | md5sum | head -c 30)
ipaddress=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
filename=config.json
rndmethod=chacha20-ietf
basedir=`cd \`dirname $0\`; pwd`
configdir=$basedir
echo "{" > $filename
echo -e "\t"\"server\":\"::\""," >> $filename
echo -e "\t"\"server_port\":"$rndport""," >> $filename
echo -e "\t"\"local_port\":1080"," >> $filename
echo -e "\t"\"password\":\""$rndpassword"\""," >> $filename
echo -e "\t"\"timeout\":600"," >> $filename
echo -e "\t"\"method\":\""$rndmethod"\" >> $filename
echo "}" >> $filename
ssserver -c $configdir"/"$filename -d start && echo -e "\n\n\033[34mSsserver已经启动\033[0m, 配置文件位于:\033[34m"$configdir"/"$filename"\033[0m, 可自行修改, 但需重启.\nIP:\033[34m"$ipaddress"\033[0m\n端口:\033[34m"$rndport"\033[0m\n密码:\033[34m"$rndpassword"\033[0m\n加密方法:\033[34m"$rndmethod"\033[0m \n\n说明:\nssserver启动命令: ssserver -c $configdir"/"$filename -d start\nssserver停止命令: ssserver -c $configdir"/"$filename -d stop\nssserver重启命令: ssserver -c $configdir"/"$filename -d restart\n"
