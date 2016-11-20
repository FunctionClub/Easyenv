######Check Root######
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
######Check Root######

######Check OS Start######
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
  OS=Ubuntu
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
  [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
  echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
  kill -9 $$
fi

if [ $(getconf WORD_BIT) == 32 ] && [ $(getconf LONG_BIT) == 64 ]; then
  OS_BIT=64
else
  OS_BIT=32
fi

######Check OS End######
clear



function InstallJava7(){
rm -rf jdk*
if [ ${OS_BIT} == 32 ];then
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-i586.tar.gz"
	tar -xf jdk-7u80-linux-i586.tar.gz && rm -rf jdk-7u80-linux-i586.tar.gz
fi

if [ ${OS_BIT} == 64 ];then
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
	tar -xf jdk-7u80-linux-x64.tar.gz && rm -rf jdk-7u80-linux-x64.tar.gz
fi
cd jdk*
mkdir /usr/local/java7
mv * /usr/local/java7/
cd ..
rm -rf jdk*

#Configure the PATH for Java7

echo "export JAVA_HOME=/usr/local/java7" >> ~/.bashrcecho "export JAVA_BIN=\$JAVA_HOME/bin">>~/.bashrc
echo "export JAVA_LIB=\$JAVA_HOME/lib">>~/.bashrc
echo "export CLASSPATH=.:\$JAVA_LIB/tools.jar:\$JAVA_LIB/dt.jar">>~/.bashrc
echo "export PATH=\$JAVA_BIN:\$PATH">>~/.bashrc
source ~/.bashrc
}


function InstallJava8(){
if [ ${OS_BIT} == 32 ];then
	rm -rf jdk*
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-i586.tar.gz"
	tar -xf jdk-8u112-linux-i586.tar.gz && rm -rf jdk-8u112-linux-i586.tar.gz
fi

if [ ${OS_BIT} == 64 ];then
	rm -rf jdk*
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz"
	tar -xf jdk-8u112-linux-x64.tar.gz && rm -rf tar -xf jdk-8u112-linux-x64.tar.gz
	
fi
cd jdk*
mkdir /usr/local/java8
mv * /usr/local/java8/
cd ..
rm -rf jdk*

#Configure the PATH for Java8

echo "export JAVA_HOME=/usr/local/java8" >> ~/.bashrc
echo "export JAVA_BIN=\$JAVA_HOME/bin">>~/.bashrc
echo "export JAVA_LIB=\$JAVA_HOME/lib">>~/.bashrc
echo "export CLASSPATH=.:\$JAVA_LIB/tools.jar:\$JAVA_LIB/dt.jar">>~/.bashrc
echo "export PATH=\$JAVA_BIN:\$PATH">>~/.bashrc
source ~/.bashrc
	
}




function InstallBasicPackages(){

if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get update -y
	apt-get install wget tar rpm build-essential -y
fi

if [ ${OS} == CentOS ];then
	yum update -y
	yum install epel-release -y
	yum install wget tar rpm -y
	yum groupinstall "Development Tools" -y
fi
}


function UninstallNodeJs(){
if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get autoremove nodejs -y
fi

if [ ${OS} == CentOS ];then
	yum remove nodejs -y
fi

#Remove the installed NodeJs via this script before.
rm -rf /usr/local/nodejs*
rm -rf /usr/local/bin/node
rm -rf /usr/local/bin/npm
}

function InstallNodeJs4(){
mkdir /usr/local/nodejs4
if [ ${OS_BIT} == 32 ];then
	wget https://nodejs.org/dist/v4.6.2/node-v4.6.2-linux-x86.tar.gz
	tar -xf node-v4.6.2-linux-x86.tar.gz -C /usr/local/nodejs4/
	rm -rf node-v4.6.2-linux-x86.tar.gz
	ln -s /usr/local/nodejs4/node-v4.6.2-linux-x86/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs4/node-v4.6.2-linux-x86/bin/npm /usr/local/bin/npm
fi

if [ ${OS_BIT} == 64 ];then
	wget https://nodejs.org/dist/v4.6.2/node-v4.6.2-linux-x64.tar.gz
	tar -xf node-v4.6.2-linux-x64.tar.gz -C /usr/local/nodejs4/
	rm -rf node-v4.6.2-linux-x64.tar.gz
	ln -s /usr/local/nodejs4/node-v4.6.2-linux-x64/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs4/node-v4.6.2-linux-x64/bin/npm /usr/local/bin/npm
fi
}

function InstallNodeJs5(){
mkdir /usr/local/nodejs5
if [ ${OS_BIT} == 32 ];then
	wget https://nodejs.org/dist/v5.9.1/node-v5.9.1-linux-x86.tar.gz
	tar -xf node-v5.9.1-linux-x86.tar.gz -C /usr/local/nodejs5/
	rm -rf node-v5.9.1-linux-x86.tar.gz
	ln -s /usr/local/nodejs5/node-v5.9.1-linux-x86/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs5/node-v5.9.1-linux-x86/bin/npm /usr/local/bin/npm
fi

if [ ${OS_BIT} == 64 ];then
	wget https://nodejs.org/dist/v5.9.1/node-v5.9.1-linux-x64.tar.gz
	tar -xf node-v5.9.1-linux-x64.tar.gz -C /usr/local/nodejs5/
	rm -rf node-v5.9.1-linux-x64.tar.gz
	ln -s /usr/local/nodejs5/node-v5.9.1-linux-x64/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs5/node-v5.9.1-linux-x64/bin/npm /usr/local/bin/npm
fi
}

function InstallNodeJs6(){
mkdir /usr/local/nodejs6
if [ ${OS_BIT} == 32 ];then
	wget https://nodejs.org/dist/v6.9.1/node-v6.9.1-linux-x86.tar.gz
	tar -xf node-v6.9.1-linux-x86.tar.gz -C /usr/local/nodejs6/
	rm -rf node-v6.9.1-linux-x86.tar.gz
	ln -s /usr/local/nodejs6/node-v6.9.1-linux-x86/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs6/node-v6.9.1-linux-x86/bin/npm /usr/local/bin/npm
fi

if [ ${OS_BIT} == 64 ];then
	wget https://nodejs.org/dist/v6.9.1/node-v6.9.1-linux-x64.tar.gz
	tar -xf node-v6.9.1-linux-x64.tar.gz -C /usr/local/nodejs6/
	rm -rf node-v6.9.1-linux-x64.tar.gz
	ln -s /usr/local/nodejs6/node-v6.9.1-linux-x64/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs6/node-v6.9.1-linux-x64/bin/npm /usr/local/bin/npm
fi
}

function InstallNodeJs7(){
mkdir /usr/local/nodejs7
if [ ${OS_BIT} == 32 ];then
	wget https://nodejs.org/dist/v7.1.0/node-v7.1.0-linux-x86.tar.gz
	tar -xf node-v7.1.0-linux-x86.tar.gz -C /usr/local/nodejs7/
	rm -rf node-v7.1.0-linux-x86.tar.gz
	ln -s /usr/local/nodejs7/node-v7.1.0-linux-x86/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs7/node-v7.1.0-linux-x86/bin/npm /usr/local/bin/npm
fi

if [ ${OS_BIT} == 64 ];then
	wget https://nodejs.org/dist/v7.1.0/node-v7.1.0-linux-x64.tar.gz
	tar -xf node-v7.1.0-linux-x64.tar.gz -C /usr/local/nodejs7/
	rm -rf node-v7.1.0-linux-x64.tar.gz
	ln -s /usr/local/nodejs7/node-v7.1.0-linux-x64/bin/node /usr/local/bin/node
	ln -s /usr/local/nodejs7/node-v7.1.0-linux-x64/bin/npm /usr/local/bin/npm
fi
}

function UninstallOpenJDK(){

if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get purge -y jdk*
fi

if [ ${OS} == CentOS ];then
	yum remove -y jdk*
fi

#Clean Installed Java via this script before
rm -rf /usr/local/java*
}




function InstallGoLang(){
if [ ${OS_BIT} == 32 ];then
	wget https://storage.googleapis.com/golang/go1.7.3.linux-386.tar.gz
	tar -C /usr/local -xzf go1.7.3.linux-386.tar.gz
	rm -rf go1.7.3.linux-386.tar.gz
fi

if [ ${OS_BIT} == 64 ];then
	wget https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.7.3.linux-amd64.tar.gz
	rm -rf go1.7.3.linux-amd64.tar.gz
fi
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
	echo "export GOPATH=$HOME/workspace" >> ~/.profile
	#Apply the Env Settings Now
	source ~/.profile
}

function InstallLua(){

#Install readline
if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get install -y libreadline-dev
fi

if [ ${OS} == CentOS ];then
	yum install -y readline readline-devel
fi

wget http://www.lua.org/ftp/lua-5.3.3.tar.gz
tar -xf lua-5.3.3.tar.gz
cd lua-5.3.3
make linux && make install
}


function InstallRuby(){

	wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.2.tar.gz && tar -xf ruby-2.3.2 && rm -rf ruby-2.3.2.tar.gz
	cd ruby-2.3.2
	./configure && make && make install
}

#Main
echo "Welcome to Easyenv!"
echo "1.Install Java"
echo "2.Install Nodejs"
echo "3.Install GoLang"
echo "4.Install Lua"
echo "5.Install Ruby && Gems"
while :; do echo
	read -p "Please input your choice: [1-5]: " chooseenv
	if [[ ! $chooseenv =~ ^[1-5]$ ]]; then
		echo "${CWARNING}input error! Please only input number!${CEND}"
	else
		break	
	fi
done

if [ $chooseenv == 1 ];then
	echo "1.Java7"
	echo "2.Java8"
	while :; do echo
		read -p "Please input your choice: [1-2]: " jdkversion
		if [[ ! $jdkversion =~ ^[1-2]$ ]]; then
			echo "${CWARNING}input error! Please only input number!${CEND}"
		else
			break
		fi
	done
	InstallBasicPackages
	UninstallOpenJDK
	if [ $jdkversion == 1 ];then
		InstallJava7
	else
		InstallJava8
	fi
fi

if [ $chooseenv == 2 ];then
	echo "1.Node.JS 4.2.6"
	echo "2.Node.JS 5.9.1"
	echo "3.Node.JS 6.9.1"
	echo "4.Node.JS 7.1.0"
	while :; do echo
		read -p "Please input your choice: [1-4]: " nodejsversion
		if [[ ! $nodejsversion =~ ^[1-4]$ ]]; then
			echo "${CWARNING}input error! Please only input number!${CEND}"
		else
			break
		fi
	done
	InstallBasicPackages
	UninstallNodeJs
	if [ $nodejsversion == 1 ];then
		UninstallNodeJs
		InstallNodeJs4
	fi
	if [ $nodejsversion == 2 ];then
		UninstallNodeJs
		InstallNodeJs5
	fi
	if [ $nodejsversion == 3 ];then
		UninstallNodeJs
		InstallNodeJs6
	fi
	if [ $nodejsversion == 4 ];then
		UninstallNodeJs
		InstallNodeJs7
	fi
fi

if [ $chooseenv == 3 ];then
	InstallGoLang
fi

if [ $chooseenv == 4 ];then
	InstallLua
fi

if [ $chooseenv == 5 ];then
	InstallRuby
fi