#!/bin/bash
# ###########################################################################
# A shell script to configure the MySQL datbase server and client.  This is
# required standalone or small demo installations of IdentityIQ.     
# Original Draft 2013/11/11 --Adam E. Hampton
# ###########################################################################

# See if we are running as the "root" user. Bail out of not running as root.
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root, giving up." 1>&2
   exit 1
fi

# Start off by setting some environment variables.  This tells us if we should
# skip the MySQL installation and configuration type entirely.
. /vagrant/scripts/setupEnv.sh

# Skip the MySQL setup if we are not using a MySQL database in our deployment
if [[ ! "$IIQDBYPE" == "mysql" ]] ; then
   echo "The IIQDBYPE is not mysql, it is: '$IIQDBYPE', skipping MySQL setup."
   exit 0
fi

# First handle CentOS or HREL, the most common installation test cases.
if [[ "$ISRHEL" -eq "1" ]] ; then

   echo "TODO: Get RedHat package manager setup for MySQL installation."
    
elif [[ "$ISCENTOS" == "1" ]] ; then

   ISMYSQLINSTALLED=`rpm -qa | grep mysql | grep -c server`
   if [[ "$ISMYSQLINSTALLED" -eq "0" ]] ; then   

      echo "Installing MySQL Server and Clinet packages..."
      yum -y install mysql mysql-server
      
      echo "Setting MySQL root user's password to '${MYSQLPW}'..."
      if [[ -z "${MYSQLPW}" ]] ; then
         echo "No MySQL password specified, leaving blank."
      else
         service mysqld start
         /usr/bin/mysqladmin -u root password "${MYSQLPW}"
         /usr/bin/mysqladmin -u root --password=${MYSQLPW} -h `hostname` password "${MYSQLPW}"
         service mysqld stop
      fi

      # Enable mysqld to auto-start on reboot.
      chkconfig --level 345 mysqld on
            
   fi
   
   if [ -f /etc/my.cnf ] ; then
      echo "Patching my.cnf to have IdentityIQ optimal values."
      sed -i -e 's/max_allowed_packet.*/max_allowed_packet=256M/' /etc/my.cnf
      FPTCNT=`grep -c innodb_file_per_table /etc/my.cnf`
      if [[ "$FPTCNT" == "0" ]] ; then
         sed -i -e 's/\[mysqld\]/\[mysqld\]\ninnodb_file_per_table=1/' /etc/my.cnf
      fi      
   fi
   
   service mysqld start
   
   echo "Completed MySQL setup for CENTOS".

elif [[ "$ISMINT" == "1" ]] ; then
   # Force Mint into 32 bit support for now.
   IS32BIT=1
   if [[ "$IS32BIT" == "1" ]] ; then
      echo "Linux Mint 32bit: Installing required packages for IIQ Lab..."

      sudo apt-get update
      sudo apt-get -y install vim
      echo On the following screens please set the MySQL root password to: "$MYSQLPW"
      sudo apt-get -y install mysql-client-core-5.5
      sudo apt-get -y install mysql-server-5.5

      # Tell MySQL to allow _huge_ packet sizes.
      if [ -f /etc/mysql/my.cnf ] ; then
         sudo sed -i -e 's/max_allowed_packet.*/max_allowed_packet=256M/' /etc/mysql/my.cnf
         # TODO: add the follwing in an automated fashion:
         # large-pages
         # innodb_buffer_pool_size = 10G
         # 
         
         FPTCNT=`grep -c innodb_file_per_table /etc/mysql/my.cnf`
         if [[ "$FPTCNT" == "0" ]] ; then
            sudo sed -i -e 's/\[mysqld\]/\[mysqld\]\ninnodb_file_per_table=1/' /etc/mysql/my.cnf
         fi
         
         sudo service mysql restart
      fi
      
      # Call out to the java setup script to install Java.
      ./javaSetup.sh
      
   else
      echo "64 Bit Mint is not yet supported, feel free to add content."
      exit
   fi
elif [[ "$ISUBUNTU" -eq "1" ]] ; then
   if [[ "$IS32BIT" == "1" ]] ; then
      echo "Ubuntu 32 bit not supported yet, feel free to add content."
   else
      echo "Ubuntu 64 bit not supported yet, feel free to add content."
   fi
   exit
else
   echo "Un-supported linux distro: "
   cat /etc/issue
   echo "Please feel free to add content to support this distro."
   exit
fi
