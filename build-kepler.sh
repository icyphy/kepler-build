#!/bin/sh

svn co https://code.kepler-project.org/code/kepler/trunk/modules/build-area

#ANT_HOME=/usr/local/apache-ant
#JAVA_HOME=/usr/java/jdk1.8.0_65
#PATH=${JAVA_HOME}/bin:/usr/local/bin:${PATH}

cd build-area
echo "JAVA_HOME: $JAVA_HOME"
echo "ANT_HOME: $ANT_HOME"
echo $PATH
which java

# Get any updates to the build area.
svn update

mkdir logs
ant change-to -Dsuite=nightly 2>&1 | grep -v GITHUB_TOKEN > logs/change-to.txt
tail -100 logs/change-to.txt

ant update
ant clean
ant compile eclipse netbeans idea

which javadoc
ant javadoc

export KEPLER_VERSION=2.4.0.1

# Remove the installers directory, the mac installer requires this.
rm -rf ../finished-kepler-installers

# Build the linux and windows installers.
ant make-linux-installer -Dversion=$KEPLER_VERSION
ant make-windows-installer -Dversion=$KEPLER_VERSION

# Copy the linux and windows installers.
#cp /var/lib/jenkins/workspace/finished-kepler-installers/windows/Kepler-$KEPLER_VERSION-win.exe /var/lib/jenkins/workspace/kepler/installers/

#cp /var/lib/jenkins/workspace/finished-kepler-installers/linux/Kepler-$KEPLER_VERSION-linux.tar.gz /var/lib/jenkins/workspace/kepler/installers/
