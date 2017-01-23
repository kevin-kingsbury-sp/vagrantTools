#/bin/bash
# ###########################################################################
# Basic variables to drive the install packages
# Set the Minimum required variables
# Minmum Required: IIQVERSION, IIQPATCHVER
# ###########################################################################

################################################################################
## Vagrant image specific variables.  These directories should match what is specified in the
## synced folders configuration in the Vagrantfile.
################################################################################
# Location of the installation images
IMAGES_DIR=/images

# Location of the tools used for various operations on this vm (i.e. provisioning scripts, etc)
TOOLS_DIR=/tools

# Location of Provisioning Scripts Directory
SCRIPTS_DIR=$TOOLS_DIR/provisioning

# Main Vagrant HOST directory
HOST_DIR=/vagrant

# Script to execute after  the environment is setup.
EXEC_SCRIPT=$1

################################################################################
## OS Specific Environment Variables
################################################################################
# Update the base OS
UPDATEOS=false

# Timezone
TZONE=America/Chicago

# The directory where we place everything.  According to the Linux Filesystem 
# Hierarchy (http://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) 
# this should be under the /opt directory of the Linux host.
IIQHOME=/opt/sailpoint

################################################################################
## IDENTITYIQ Specific Environment Variables
################################################################################
# Install IIQ?
INSTIIQ=true

# Directory where the IdentityIQ images are stored
# This folder should be setup in the Vagrantfile as a mounted folder
IIQIMAGES=$IMAGES_DIR/identityiq

# Where underneath tomcat web application will IIQ be installed.  This is typically
# "$TOMCAT/webapps/identityiq", only the end identityiq needs to be specified here.
WEBAPPDIR=identityiq

# What version of IIQ are we installing here?
# The versions will be used to find the install files in the 
# IIQIMAGES directory
IIQVERSION=7.0
IIQPATCHVER=

################################################################################
## DEMO DATA Specific Environment Variables
################################################################################
# Install the DemoData?
DEMODATA=false
# DemoData file
DEMODATAZIP=${IIQIMAGES}/DemoData/DemoData-${IIQVERSION}.zip

################################################################################
## JAVA Specific Environment Variables
################################################################################
# What version of Java are we installing here?
# This should be simplified 1.6, 1.7 etc. Standard URL and version
# Example: JAVAPKGFILE=jdk-7u45-linux.tar.gz
# Example: JAVAURL=http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-i586.tar.gz
JAVAIMAGES=$IMAGES_DIR/jdk
#JAVAPKGFILE=jdk-7u51-linux-i586.tar.gz
JAVAPKGFILE=jdk-8u65-linux-i586.tar.gz
JAVAURL=http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-i586.tar.gz

################################################################################
## Tomcat Specific Environment Variables
################################################################################
TCIMAGES=$IMAGES_DIR/tomcat
TCVERSION=7.0.65
# Where tomcat gets installed underneath the SailPoint IIQ base/home directory:
TCTHOME=$IIQHOME/tomcat
# Where the tomcat binaries will be placed
TCPKGFILE=apache-tomcat-${TCVERSION}.tar.gz
# The URL for the tomcat version to install
TCPKGURL=http://apache.mirrors.pair.com/tomcat/tomcat-7/v${TCVERSION}/bin/apache-tomcat-${TCVERSION}.tar.gz

#This is the port forwarded on the host
#Configure this in the vagrant file
HOST_TC_PORT=8081

################################################################################
## MYSQL Specific Environment Variables
################################################################################
MYSQLPW="password"

################################################################################
## OTHER Specific Environment Variables.  Probably dont need to change these.
################################################################################
# Set the OS type to centos
ISCENTOS=`cat /etc/issue | grep -c -i centos`

# Flag telling us what database type to configure.  If this is anything other
# than 'mysql' then the scripts will skip installing the MySQL Database 
# system on the Linux server.
IIQDBYPE=mysql

# TODO add some validation logic here to check required variables.

export IMAGES_DIR TOOLS_DIR SCRIPTS_DIR HOST_DIR UPDATEOS TZONE INSTIIQ IIQVERSION IIQPATCHVER IIQIMAGES DEMODATA DEMODATAZIP IIQHOME JAVAIMAGES JAVAPKGFILE JAVAURL IIQHOME TCIMAGES TCVERSION TCTHOME TCPKGFILE TCPKGURL WEBAPPDIR ISCENTOS IIQDBYPE HOST_TC_PORT MYSQLPW

if [[ -f "${SCRIPTS_DIR}/${EXEC_SCRIPT}" ]]; then
    $SCRIPTS_DIR/$EXEC_SCRIPT
fi