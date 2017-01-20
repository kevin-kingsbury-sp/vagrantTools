#bin/bash
# ###########################################################################
# A shell script to install a laboratory instance of IdentityIQ on a Linux
# environment.   
# Author: Adam E. Hampton (adam.hampton@sailpoint.com), scott.lindsey@sailpoint.com
# ###########################################################################

# Calculate the name of the GA identityIQ installation file.
GAINSTALLFILE=identityiq-${IIQVERSION}.zip

echo Deploying IdentityIQ GA $GAINSTALLFILE under Tomcat...
mkdir -p ${TCTHOME}/webapps/${WEBAPPDIR}
mkdir -p ${IIQHOME}/iiqInstallBits
cd ${IIQHOME}/iiqInstallBits
jar -xvf ${IIQIMAGES}/${GAINSTALLFILE}
cd ${TCTHOME}/webapps/${WEBAPPDIR}
jar -xvf ${IIQHOME}/iiqInstallBits/identityiq.war
echo GA install file deployed.

echo Creating IdentityIQ database in MySQL...
cd ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/database
mysql --user=root --password=$MYSQLPW < create_identityiq_tables-${IIQVERSION}.mysql
echo Done creating IdentityIQ database in MySQL.

echo Importing intial setup of IdentityIQ...
cd ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/bin
chmod 755 ./iiq
echo -n "import init.xml" | ./iiq console
#TODO make lcm optional
echo -n "import init-lcm.xml" | ./iiq console
cd -
echo Done importing intial setup of IdentityIQ.

echo Removing IIQ version of el-api.jar...
cd ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/lib
mv el-api*.jar el-api.jar.disabled

cd -
echo Done removing IIQ version of el-api.jar...

if [[ "x${IIQPATCHVER}" == "x" ]] ; then
	echo No patch version specified for installation, skipping patch.
else
	echo Unzipping patch files for IIQ patch ${IIQVERSION}${IIQPATCHVER}...
	cp ${IIQIMAGES}/identityiq-${IIQVERSION}${IIQPATCHVER}.jar ${IIQHOME}/iiqInstallBits/.
	cp ${IIQIMAGES}/identityiq-${IIQVERSION}${IIQPATCHVER}-README.txt ${IIQHOME}/iiqInstallBits/.
	cd ${TCTHOME}/webapps/${WEBAPPDIR}
	jar -xvf ${IIQHOME}/iiqInstallBits/identityiq-${IIQVERSION}${IIQPATCHVER}.jar
	cd -
	echo Patch file unzipped.
	echo Patching database to $IIQPATCHVER...
	cd ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/database
	mysql --user=root --password=$MYSQLPW -f -v < upgrade_identityiq_tables-${IIQVERSION}${IIQPATCHVER}.mysql
	cd -
	echo database patched.
	echo Importing patched setup of IdentityIQ...
	cd ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/bin
	chmod 755 ./iiq
	./iiq patch ${IIQVERSION}${IIQPATCHVER}
	
	#Really?  We should never have to re-import after a patch
	#echo -n "import init.xml" | ./iiq console
	#echo -n "import init-lcm.xml" | ./iiq console
	cd -
	echo Done importing patched setup of IdentityIQ.
fi

