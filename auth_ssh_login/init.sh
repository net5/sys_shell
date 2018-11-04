#!/bin/bash
#此脚本实现功能:将ssh_init.sh复制到远程主机并执行

#安装expect，实现运行过程自动应答
if [ `rpm -qa | grep expect | wc -l` -eq 0 ]
then
    yum install expect -y
fi

#集群IP
SERVERS="192.168.105.231 192.168.105.232 192.168.105.233 192.168.105.234 192.168.105.235"

#每台远程主机的机器密码
PASSWORD="password"

#复制ssh_init.sh到远程主机  
ssh_file(){  
    expect -c "set timeout -1;  
        spawn scp ssh_init.sh root@$1:/root/  
        expect {  
            *(yes/no)* {send -- yes\r;exp_continue;}  
            *password:* {send -- $2\r;exp_continue;}  
            eof        {exit 0;}  
        }";  
}

#在远程主机上执行ssh_init.sh  
execute_sh(){  
    expect -c "set timeout -1;  
        spawn ssh root@$SERVER /root/ssh_init.sh  
        expect {  
            *(yes/no)* {send -- yes\r;exp_continue;}  
            *password:* {send -- $2\r;exp_continue;}  
            eof        {exit 0;}  
        }";  
}

#遍历 将ssh复制到远程主机并执行  
for SERVER in $SERVERS  
do  
    ssh_file $SERVER $PASSWORD  
    execute_sh $SERVER $PASSWORD  
done
