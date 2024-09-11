#!/bin/bash

initialize="/opt/.initialize.log"

if [ -e "$initialize" ];then
    #echo "存在"
    echo "=============================================================================================================="
    echo -e "\e[31m 请选择要执行的脚本: \e[39m"
    echo "1. 安装hadoop"
    echo "2. 网络配置"
    echo "3. 修改时区"
    echo "=============================================================================================================="
    read -p "请输入数字: `echo $'\n>'` " num
    case $num in
    1)
        if rpm -qa | grep -q jdk ; then
            echo "JDK is installed."
        else
            echo "安装java_8环境"
            yum install java-1.8.0-openjdk -y
            echo "java_initialize=ok" >> $initialize # 写入日志文件
        fi

        # if rpm -qa | grep -q hadoop ; then
        #     echo "hadoop is installed."
        # else
        #     echo "下载hadoop-3.4.0"
        # if

        echo -e "\e[31m 1.本地安装hadoop"
        echo -e "2.远程安装hadoop \e[39m"
        read -p "请输入数字: `echo $'\n>'` " install_hadoop
        case $install_hadoop in
        1)
            read -p "请输入hadoop包的“绝对路径”: `echo $'\n>'` " hadoop_local
            tar -zxvf $hadoop_local -C /opt/
            echo "hadoop_inustall=ok-local" >> $initialize # 写入日志文件
            hadoop_local=${hadoop_local##*/}
            hadoop_local=$(basename -- "$hadoop_local" ".tar.gz")
            sed -i "2c file_hadoop=/opt/${hadoop_local}" ./function/hadoop-init.sh
            ./function/hadoop-init.sh
        
        ;;  
        2)
            echo "下载hadoop-3.4.0"
            curl -o /opt/hadoop-3.4.0.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/core/hadoop-3.4.0/hadoop-3.4.0.tar.gz
            tar -zxvf /opt/hadoop-3.4.0.tar.gz -C /opt/
            sed -i "2c file_hadoop=/opt/hadoop-3.4.0" ./function/hadoop-init.sh
            echo "hadoop_inustall=ok-remote" >> $initialize # 写入日志文件

            ./function/hadoop-init.sh

        ;;  
        *)
            echo "error choice"
        ;;
        esac
        ;;  
    2)
        echo "网络配置"
        read -p "请输入master的ip:" master_ip
        read -p "请输入slave1的ip:" slave1_ip
        read -p "请输入slave2的ip:" slave2_ip
        read -p "请输入slave2的ip:" slave3_ip

        sed -i "10c$master_ip master " >> /etc/hosts
        sed -i "11C$slave1_ip slave1" >> /etc/hosts
        sed -i "12c$slave2_ip slave2" >> /etc/hosts
        sed -i "13c$slave3_ip slave3" >> /etc/hosts
        systemctl restart network
        echo -e "\e[31m 网络配置完成,已重启网卡 \e[39m"
        echo "network_master=$master" >> $initialize # 写入日志文件
        echo "network_slave1=$slave1" >> $initialize # 写入日志文件
        echo "network_slave2=$slave2" >> $initialize # 写入日志文件

    ;;
    3)
        echo "修改时区为China"
        timedatectl set-timezone Asia/Shanghai # 修改时区为China
    ;;
    *)
        echo "error choice"
    ;;
    esac
else
    # echo "不存在"
    touch "$initialize" 

    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    echo "yum_initialize=ok" >> $initialize
    echo "yum已换成China国内源"

    echo "/usr/sbin/sshd" >> /etc/rc.local
    echo "sshd_initialize=ok" >> $initialize
    echo "sshd已开机自启"

    yum install kde-l10n-Chinese #安装中文语言包
    localectl set-locale LANG=zh_CN.UTF8 #设置语言环境
    echo "设置中文环境"

    echo "基础环境初始化完成,请重启,再执行CentOS_initialize.sh"

fi

