#Main






#Functions

function CheckOS(){

if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then OS=Ubuntu
 ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
    kill -9 $$
fi
if [ $(getconf WORD_BIT) == 32 ] && [ $(getconf LONG_BIT) == 64 ];then
    OS_BIT=64
else
    OS_BIT=32
fi


}

function UninstallOpenJDK(){
if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get purge openjdk* -y
fi

if [ ${OS} == CentOS ];then
	yum remove java* -y
fi

}

function InstallJava8(){
if [ ${OS_BIT} == 32];then
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-i586.tar.gz"
	rm -rf jdk*
	tar -xf jdk-8u112-linux-i586.tar.gz
	cd jdk*
	mkdir /usr/local/java8
	mv * /usr/local/java8/
fi

#Configure the PATH for Java8

echo "export JAVA_HOME=/usr/local/java8" >> ~/.bashrc
echo "export JAVA_BIN=$JAVA_HOME/bin">>~/.bashrc
echo "export JAVA_LIB=$JAVA_HOME/lib">>~/.bashrc
echo "export CLASSPATH=.:$JAVA_LIB/tools.jar:$JAVA_LIB/dt.jar">>~/.bashrc
echo "export PATH=$JAVA_BIN:$PATH">>~/.bashrc
source ~/.bashrc
	
}

function CheckIfRoot(){

[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

}

function InstallBasicPackages(){

if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
	apt-get install wget tar rpm build-essential -y
fi

if [ ${OS} == CentOS ];then
	yum install epel-release -y
	yum install wget tar rpm -y
	yum groupinstall "Development Tools" -y
fi
}
