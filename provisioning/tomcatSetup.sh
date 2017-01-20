#bin/bash
# ###########################################################################
# Install an IdentityIQ friendly tomcat
# ###########################################################################
# Need to make min/max/perm size configurable from properties file

# Start off by setting some environment variables...
# . ./setupEnv.sh

echo Installing Tomcat

# Build out an directory structure to house IIQ and its accessories.
mkdir -p $TCTHOME

if [[ -f "${TCIMAGES}/${TCPKGFILE}" ]] ; then
   TCARCHIVE=${TCIMAGES}/${TCPKGFILE}
else
   TCARCHIVE=/tmp/${TCPKGFILE}

   # Download the bits
   wget -O $TCARCHIVE $TCPKGURL
fi

# Install apache tomcat into the tomcat directory. Cleanup names en route.
if [[ -f $TCARCHIVE ]] ; then
   tar -zxvf $TCARCHIVE --directory=$TCTHOME
else
   echo "ERROR: Could not find a tomcat archive to extract!"
   echo "Look for $TCARCHIVE"
fi

TCTBASE=`ls $TCTHOME`
mv $TCTHOME/${TCTBASE}/* $TCTHOME
rmdir $TCTHOME/${TCTBASE}/
chmod 755 $TCTHOME/bin/*.sh

echo Patching catalina.sh to include Sun Java options...
cd $TCTHOME/bin
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}i# Begin patch to support IdentityIQ on Sun/Oracle Java ---"
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Dsun.lang.ClassLoader.allowArraySyntax=true \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Djava.awt.headless=true \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Xmx768m -Xms256m -XX:PermSize=128m \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Djavax.xml.soap.SOAPConnectionFactory=org.apache.axis.soap.SOAPConnectionFactoryImpl \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Djavax.xml.soap.MessageFactory=org.apache.axis.soap.MessageFactoryImpl \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}iJAVA_OPTS=\"-Djavax.xml.soap.SOAPFactory=org.apache.axis.soap.SOAPFactoryImpl \$JAVA_OPTS\""
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}i# -End- patch to support IdentityIQ on Sun/Oracle Java ---"
sed -i "$SEDCMD" catalina.sh
INSLINE=`grep -n "OS specific" catalina.sh | cut -d':' -f 1`
SEDCMD="${INSLINE}i\\\\n"
sed -i "$SEDCMD" catalina.sh
cd -
echo Done patching catalina.sh for Sun Java options.

# Not sure why we create these extra scripts - TODO Remove?
echo Creating canned start/stop scripts...
echo "#!/bin/bash"                                     > startTomcat.sh
echo "export CATALINA_OPTS=\"-Dsailpoint.debugPages=true\"" > startTomcat.sh
echo "/opt/sailpoint/tomcat/bin/catalina.sh start"  >> startTomcat.sh
echo "#!/bin/bash"                                     > startTomcatDebug.sh
echo "export CATALINA_OPTS=\"-Dsailpoint.debugPages=true\"" > startTomcatDebug.sh
echo "/opt/sailpoint/tomcat/bin/catalina.sh jpda start"  >> startTomcatDebug.sh
echo "#!/bin/bash"                                     > stopTomcat.sh
echo "/opt/sailpoint/tomcat/bin/catalina.sh stop"  >> stopTomcat.sh
echo "#!/bin/bash"                                     > tailTomcatLog.sh
echo "tail -f /opt/sailpoint/tomcat/logs/catalina.out"  >> tailTomcatLog.sh
chmod 755 *.sh
echo Done creating canned scripts.

echo "Tomcat installed"
