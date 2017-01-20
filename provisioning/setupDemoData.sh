#bin/bash
# ###########################################################################
# A shell script to import the IIQ demo data.
# ###########################################################################

# Start off by setting some environment variables...
# . ./setupEnv.sh

echo Importing IIQ demo data
cd ${TCTHOME}/webapps/${WEBAPPDIR}/
jar -xvf ${DEMODATAZIP}

# Import the importAll.xml file and this takes care of everything else
# echo -n "import WEB-INF/config/demo/importAll.xml" | ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/bin/iiq console
# Import only the demo objects and data minus the test team objects
echo -n "import WEB-INF/config/demo/demoImport.xml" | ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/bin/iiq console
echo Done importing demo data

echo Running demo setup tasks
echo -n "run setupDemoTask" | ${TCTHOME}/webapps/${WEBAPPDIR}/WEB-INF/bin/iiq console
echo Done setting up demo data

