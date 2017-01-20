#!/bin/sh
# Main bootstrap file for the box
# TODO - Add a separate log for debugging and install messages

SCRIPTS_DIR=/vagrant/scripts
export SCRIPTS_DIR

# Setup the environment variables
. $SCRIPTS_DIR/setupEnv.sh

if [[ "$UPDATEOS" == "true" ]] ; then
   # Update the base centos packages - TODO should we do this?
   sudo yum -y update
fi

# Create the sailpoint directory and change ownership to vagrant user.
sudo mkdir -p $IIQHOME
sudo chown vagrant:vagrant $IIQHOME

# set the timezone 
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/$TZONE /etc/localtime

# Install glibc for the JDK
sudo yum -y install glibc.i686
# Make sure libgcc is up to date
sudo yum -y install libgcc
# Certs wouldn't display without this
sudo yum -y install libgcc_s.so.1
# Make sure we have the right fonts installed
sudo yum -y install libXfont

# Install JDK
sudo $SCRIPTS_DIR/javaSetup.sh

# Install Tomcat
$SCRIPTS_DIR/tomcatSetup.sh

# Install MySQL
sudo $SCRIPTS_DIR/mysqlSetup.sh

# Install IdentityIQ
if [[ "$INSTIIQ" == "true" ]] ; then
   $SCRIPTS_DIR/iiqSetup.sh
fi

# Install DemoData
if [[ "$DEMODATA" == "true" ]] ; then
   $SCRIPTS_DIR/setupDemoData.sh
fi

# Start Tomcat
~/startTomcat.sh

# Setup bash shell
echo "set -o emacs" >> /home/vagrant/.bash_profile
echo "SPHOME=/opt/sailpoint/tomcat/webapps/identityiq" >> /home/vagrant/.bash_profile
echo "export SPHOME" >> /home/vagrant/.bash_profile

echo iiqbox is up!
echo Open http://localhost:${HOST_TC_PORT}/identityiq
