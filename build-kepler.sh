#!/bin/sh

# Build Kepler, the Scientific Workflow System
# See https://kepler-project.org
# See https://travis-ci.org/icyphy/kepler-build

svn co https://code.kepler-project.org/code/kepler/trunk/modules/build-area

cd build-area

#ANT_HOME=/usr/local/apache-ant
#JAVA_HOME=/usr/java/jdk1.8.0_65
#PATH=${JAVA_HOME}/bin:/usr/local/bin:${PATH}

echo "JAVA_HOME: $JAVA_HOME"
echo "ANT_HOME: $ANT_HOME"
echo $PATH
which java

# Get any updates to the build area.  Probably not necessary, but
# never a bad idea.
svn update


# Change to the nightly suite.  The output has too many lines for
# Travis-ci, so we put it in a log.
mkdir logs
LOG=logs/change-to.txt
echo "Running 'ant change-to -Dsuite=nightly', redirecting output to $LOG: `date`"
ant change-to -Dsuite=nightly 2>&1 | grep -v GITHUB_TOKEN > $LOG

echo "Last 100 lines of $LOG: `date`"
tail -100 $LOG


# Build it.
ant update
ant clean
ant compile eclipse netbeans idea


# Run Javadoc.  The output has too many lines, so we put it in a log.
which javadoc
LOG=logs/javadoc.txt
echo "Running 'ant change-to -Dsuite=nightly', redirecting output to $LOG: `date`"
ant javadoc 2>&1 | grep -v GITHUB_TOKEN > $LOG

echo "Last 100 lines of $LOG: `date`"
tail -100 $LOG


# Build the installers
export KEPLER_VERSION=2.4.0.1

# Remove the installers directory, the mac installer requires this.
rm -rf ../finished-kepler-installers

# case `uname` in \
#     Darwin) osfile=macosx-x86;; \
#     Linux) osfile=linux-x64;; \
# esac; \

# L4J_TAR=/tmp/launch4j-3.11.tgz
# echo "Downloading  for $osfile: `date`";
# wget "https://osdn.net/frs/g_redir.php?m=kent&f=launch4j%2Flaunch4j-3%2F3.11%2Flaunch4j-3.11-$$osfile.tgz" -O $L4J_TAR

ls -l resources || true
ls -l resources/installer || true

# mkdir -p resources/installer

# (cd resources/installer/; tar -zxf $L4J_TAR)

ls -l resources/installer/launch4j/bin-linux
ls -l resources/installer/launch4j/bin-linux/windres
ls -l /home/travis/build/icyphy/kepler-build/build-area/resources/installer/launch4j/bin-linux/windres

# Build the linux and windows installers.
ant make-linux-installer -Dversion=$KEPLER_VERSION

ls -l resources/installer/launch4j/bin-linux/windres
ls -l /home/travis/build/icyphy/kepler-build/build-area/resources/installer/launch4j/bin-linux/windres

ant make-windows-installer -Dversion=$KEPLER_VERSION

echo "HOME: $HOME:"
ls $HOME
echo "../../finished-kepler-installers:"
ls -l ../../finished-kepler-installers

echo "/home/travis/build/icyphy/:"
ls -l /home/travis/build/icyphy/

echo "/home/travis/build/icyphy/finished-kepler-installers"
ls -lR /home/travis/build/icyphy/finished-kepler-installers


