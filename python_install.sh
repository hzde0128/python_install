#!/bin/bash
# python2.7.12及其相关的包
# 新版本基于国内pip源在线安装，支持centos6/7
# 更新于2017-02-03
CURRENT_DIR=$(dirname $(readlink -f $0))

echo -e "\033[32m+------------------------------------------------------------+\033[0m"
echo -e "\033[32m|                 Python27环境自动安装脚本                   |\033[0m"
echo -e "\033[32m|                    适用平台CentOS6.X/7.X                   |\033[0m"
echo -e "\033[32m|                                                            |\033[0m"
echo -e "\033[32m|                                      Author:Jerry          |\033[0m"
echo -e "\033[32m|                                      Date:2017-02-03       |\033[0m"
echo -e "\033[32m+------------------------------------------------------------+\033[0m"

sleep 3

if [ `id -u` -ne 0 ];then
	echo "请使用root运行此脚本"
	exit
fi


#安装依赖
yum -y install epel-release
yum -y install gcc gcc-c++ python-devel openssl openssl-devel zlib zlib-devel xz unzip mysql-devel

#检测系统版本
OS_VERSION=`cat /etc/system-release | awk -F. '{print $1 }' | awk '{print $NF}'`

if [  ${OS_VERSION}  -eq 6  ]
then
	#检测是否已经安装python-2.7.12
	if [ -e $CURRENT_DIR/python27.tag ];then
		echo "已经安装python2.7.12"
	else
	    #安装python-2.7.12
		tar xf Python-2.7.12.tar.gz
		cd Python-2.7.12
		./configure --prefix=/usr/local/python --enable-shared
		make
		make install
		ln -svf /usr/local/python/bin/python2.7 /usr/bin/python
		sed -i s/python/python2.6/ /usr/bin/yum
		echo /usr/local/python/lib >/etc/ld.so.conf
		ldconfig
		python -V
		cd $CURRENT_DIR
		touch python27.tag
	fi
fi

if [ ! -d /root/.pip ];then
	mkdir -p /root/.pip
fi

if [ ! -e /root/.pip/pip.conf ];then
echo "[global]" > /root/.pip/pip.conf
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /root/.pip/pip.conf
fi

# 安装setuptools和pip
if [  ${OS_VERSION} -eq 6  ];then
	cd $CURRENT_DIR
	tar xf setuptools-29.0.1.tar.gz
	cd setuptools-29.0.1
	python setup.py build
	python setup.py install
	cd $CURRENT_DIR
	tar xf pip-9.0.1.tar.gz
	cd pip-9.0.1
	python setup.py install
	ln -sf /usr/local/python/bin/pip /usr/bin/
else
	yum -y install python-setuptools python-pip
	pip install pip --upgrade
fi

#安装SQLAlchemy-1.0.14

pip install SQLAlchemy==1.0.14


#安裝MySQL-python-1.2.5
#EnvironmentError: mysql_config not found
[ -d /usr/local/mysql/bin ]&&export PATH=$PATH:/usr/local/mysql/bin
pip install  MySQL-python==1.2.5
echo "安装完毕。"
