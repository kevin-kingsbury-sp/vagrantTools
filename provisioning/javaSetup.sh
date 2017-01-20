#bin/bash
# ###########################################################################
# A shell script to install a Java JDK/JVM onto a Linux server. 
# Part of the LinuxLIIQtitySplit package of Linux support tools.
#
# Author: Adam E. Hampton (adam.hampton@sailpoint.com)
# Modified for Vagrant: scott.lindsey@sailpoint.com
# ###########################################################################

# You must setup some environment variables.  This includes what 
# versions of Java we will be installing.  See the Env script for details.
. /vagrant/scripts/setupEnv.sh

echo Performing Java JDK/JVM installation for Linux...

# ###########################################################################
# Ideally IIQ should be installed on a 64 bit platform but for the purposes
# of supporting virtual machines we support installing on 32 bit here too.
# Note: IdentityIQ 6.x officially supports being installed on the following:
#    SuSE Linux ES 10 and 11, Red Hat Enterprise 5 and 6.
# This script adds support for installing on these other environments:
#    Ubuntu Linux 12.04+, Linux Mint 13-15, CentOS 5 and 6
# ###########################################################################

# Check for the prerequisite files before proceeding with the installation.
if [[ "$JAVAPKGFILE" == "" ]] ; then
   echo "ERROR: Please specify a value for the JAVAPKGFILE variable."
   echo "       Example: JAVAPKGFILE=jre-7u25-linux.tar.gz"
   exit 1
fi  
if [[ "$JAVAURL" == "" ]] ; then
   echo "ERROR: Please specify a value for the JAVAURL variable."
   echo "       Example: JAVAURL=http://oracle.com/downloads/jdk1.7.tgz"
   exit 1
fi  

if [[ -f "${JAVAIMAGES}/${JAVAPKGFILE}" ]] ; then
   JAVAARCHIVE=${JAVAIMAGES}/${JAVAPKGFILE}
else
   JAVAARCHIVE=/tmp/${JAVAPKGFILE}

   # Download directly from Oracle
   wget --no-check-certificate --no-cookies - --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVAURL -O $JAVAARCHIVE

   if [[ ! -f "${JAVAARCHIVE}" ]] ; then
      echo "ERROR: cound not fine Java package file: $JAVAPKGFILE"
      echo "       Please make sure it is copied into /tmp/"
      exit 1
   fi
fi

if [[ "$ISMINT" -eq "1" ]] || [[ "$ISUBUNTU" -eq "1" ]] || 
   [[ "$ISRHEL" -eq "1" ]] || [[ "$ISCENTOS" -eq "1" ]] ; then
	
   # Now install java the yucky, manual way.  It's painstaking but
   # effective and makes sure we get the correct version of Java in path.
   echo "Extracting Java package $JAVAPKGFILE ..."
	mkdir -p /usr/local/java
   	
	# Copy and un-zip the java package to /usr/local/java/...
	cp $JAVAARCHIVE /usr/local/java
	cd /usr/local/java		
	cat $JAVAPKGFILE | gunzip | tar -xvf -
	
	# Figure out what directory we just wrote to.
	# Do this in a version-independent manner.
	PKGDIR=`ls -atrd */ | sed -e's/\///g' | tail -n 1`
	chown -R root:root $PKGDIR
	
	# Setup the system path variables to point to the new java by default.
	# According to information from 
	#    https://help.ubuntu.com/community/EnvironmentVariables
	# the best options here are either /etc/environment or /etc/bash.bashrc
	# We chose the first one:
	sed -i -e"s,\"$,:${PKGDIR}/bin\",g" /etc/environment
	
	# Remove the tar-ball file to save space in /usr/local/java.
	rm -f $JAVAPKGFILE
	
	# Change back to the script's home directory.
	cd -
	
	echo Setting Oracle/Sun java as primary java/javac...
	ULJ=/usr/local/java
	update-alternatives --install /usr/bin/java     java     ${ULJ}/${PKGDIR}/bin/java 1
	update-alternatives --install /usr/bin/javac    javac    ${ULJ}/${PKGDIR}/bin/javac 1
	update-alternatives --install /usr/bin/jar      jar      ${ULJ}/${PKGDIR}/bin/jar 1
	update-alternatives --install /usr/bin/jconsole jconsole ${ULJ}/${PKGDIR}/bin/jconsole 1
	update-alternatives --install /usr/bin/javadoc  javadoc  ${ULJ}/${PKGDIR}/bin/javadoc 1
	
	echo Currently Installed Java Versions:
	if [[ "$ISRHEL" == "1" ]] || [[ "$ISCENTOS" == "1" ]] ; then
	   update-alternatives --display java
	else
	   update-alternatives --list java
	fi	
	update-alternatives --set java     ${ULJ}/${PKGDIR}/bin/java
	update-alternatives --set javac    ${ULJ}/${PKGDIR}/bin/javac
	update-alternatives --set jar      ${ULJ}/${PKGDIR}/bin/jar
	update-alternatives --set jconsole ${ULJ}/${PKGDIR}/bin/jconsole
	update-alternatives --set javadoc  ${ULJ}/${PKGDIR}/bin/javadoc
	
	echo Using Java and JavaC JDK versions:
	java -version
	javac -version      		
      
fi

exit
