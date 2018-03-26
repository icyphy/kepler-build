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
LOG=logs/change-to.txt
echo "Running 'ant change-to -Dsuite=nightly', redirectoing output to $LOG: `date`"
ant change-to -Dsuite=nightly 2>&1 | grep -v GITHUB_TOKEN > $LOG

echo "Last 100 lines of $LOG: `date`"
tail -100 $LOG

ant update
ant clean
ant compile eclipse netbeans idea

which javadoc
LOG=logs/javadoc.txt
echo "Running 'ant change-to -Dsuite=nightly', redirectoing output to $LOG: `date`"
ant javadoc 2>&1 | grep -v GITHUB_TOKEN > $LOG

echo "Last 100 lines of $LOG: `date`"
tail -100 $LOG


export KEPLER_VERSION=2.4.0.1

# Remove the installers directory, the mac installer requires this.
rm -rf ../finished-kepler-installers

case `uname` in \
    Darwin) osfile=macosx-x86;; \
    Linux) osfile=linux-x64;; \
esac; \

L4J_TAR=/tmp/launch4j-3.11.tgz
echo "Downloading  for $osfile: `date`";
wget --quiet "https://osdn.net/frs/g_redir.php?m=kent&f=launch4j%2Flaunch4j-3%2F3.11%2Flaunch4j-3.11-$$osfile.tgz" -O $L4J_TAR

ls -l resources || true
ls -l resources/installer || true

mkdir -p resources/installer

(cd resources/installer/; tar -zxf $L4J_TAR)

# Build the linux and windows installers.
ant make-linux-installer -Dversion=$KEPLER_VERSION
ant make-windows-installer -Dversion=$KEPLER_VERSION

# Copy the linux and windows installers.
#cp /var/lib/jenkins/workspace/finished-kepler-installers/windows/Kepler-$KEPLER_VERSION-win.exe /var/lib/jenkins/workspace/kepler/installers/

#cp /var/lib/jenkins/workspace/finished-kepler-installers/linux/Kepler-$KEPLER_VERSION-linux.tar.gz /var/lib/jenkins/workspace/kepler/installers/
