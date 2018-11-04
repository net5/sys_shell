#!/bin/bash
#脚本实现功能:在本机生成公钥，并copy至其他主机

#安装expect,实现自动应答
if [ `rpm -qa | grep expect | wc -l` -eq 0 ]
then
    yum install expect -y
fi

#集群IP
SERVERS="192.168.105.231 192.168.105.232 192.168.105.233 192.168.105.234 192.168.105.235"

#每台远程主机的机器密码
PASSWORD="password"

#自动把本地主机的公钥复制到远程主机
auto_ssh_copy_id(){
	#expect 人机交互
	expect -c "set timeout -1;
		#执行命令
		spawn ssh-copy-id $1;
		expect {
			#如果提示yes/no, 输入yes,继续
			*(yes/no)* {send -- yes\r;exp_continue;}
			#如果提示password, 输入密码回车,继续
			*password:* {send -- $2\r;exp_continue;}
			#交互结束,退出
			eof        {exit 0;}
		}";
}

#获取ssh公钥
get_rsa(){
	expect -c "set timeout -1;
		spawn ssh-keygen -t rsa;
		expect {
			*Enter* {send -- \r;exp_continue;}
			#如果已存在公钥,则进行覆盖
			*Overwrite* {send -- y\r;exp_continue;}
			#交互结束,退出
			eof        {exit 0;}
		}";
}
 
get_rsa
 
#循环遍历所有远程主机,自动把本地主机的公钥复制到远程主机
for SERVER in $SERVERS
do
	auto_ssh_copy_id $SERVER $PASSWORD
done
