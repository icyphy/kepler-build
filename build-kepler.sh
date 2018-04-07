#!/bin/bash -e

# Use -e so that if the build fails, then travis will tell us so.

# Build Kepler, the Scientific Workflow System
# See https://kepler-project.org
# See https://travis-ci.org/icyphy/kepler-build


# Copy the file or directory named by
# source-file-or-directory to directory-in-gh-pages.  For example
#   updateGhPages logs/installers.txt logs
# will copy logs/installers.txt to logs in the gh-pages and push it.
# If the last argument ends in a /, then a directory by that name is created.
# The reason we need this is because the Travis deploy to gh-pages seems
# to overwrite everything in the repo.
# Usage:
#   updateGhPages fileOrDirectory1 [fileOrDirectory2 ...] destinationDirectory
#
updateGhPages () {
    length=$(($#-1))
    sources=${@:1:$length}
    destination=${@: -1}

    if [ -z "$GITHUB_TOKEN" ]; then
        echo "$0: GITHUB_TOKEN was not set, so $sources will not be copied to $destination in the gh-pages repo."
        return 
    fi

    df -k
    TMP=/tmp/ptIITravisBuild_gh_pages.$$
    if [ ! -d $TMP ]; then
        mkdir $TMP
    fi
    lastwd=`pwd`
    cd $TMP

    # Get to the Travis build directory, configure git and clone the repo
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "travis-ci"

    # Don't echo GITHUB_TOKEN
    set +x
    git clone --depth=1 --single-branch --branch=gh-pages https://${GITHUB_TOKEN}@github.com/icyphy/kepler-build gh-pages
    set -x

    df -k
    # Commit and Push the Changes
    cd gh-pages
    echo "$destination" | grep '.*/$'
    status=$?
    if [ $status -eq 0 ]; then
        if [ ! -d $destination ]; then
            mkdir -p $destination
            echo "$0: Created $destination in [pwd]."
        fi
    fi        

    cp -Rf $sources $destination

    # JUnit xml output will include the values of the environment,
    # which can include GITHUB_TOKEN, which is supposed to be secret.
    # So, we remove any lines checked in to gh-pages that mentions
    # GITHUB_TOKEN.
    echo "Remove any instances of GITHUB_TOKEN: "
    date
    # Don't echo GITHUB_TOKEN
    set +e
    set +x
    files=`find . -type f`
    for file in $files
    do
        egrep -e  "GITHUB_TOKEN" $file > /dev/null
	retval=$?
	if [ $retval != 1 ]; then
            echo -n "$file "
            egrep -v "GITHUB_TOKEN" $file > $file.tmp
            mv $file.tmp $file
        fi
    done        
    #set -x
    echo "Done."
    set -e

    git add -f .
    date
    # git pull
    date
    git commit -m "Lastest successful travis build $TRAVIS_BUILD_NUMBER auto-pushed $1 to $2 in gh-pages."
    git pull 
    git push origin gh-pages
    git push -f origin gh-pages

    cd $lastwd
    rm -rf $TMP
}



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


# Change to the nightly suite.

# The output has too many lines for Travis-ci, so we put it in a log.
if [ ! -d logs ]; then
    mkdir logs
fi

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

# Add javadoc files to the gh-pages branch so that they appear at
# https://icyphy.github.io/kepler-build/doc/javadoc/index.html
(cd ..; updateGhPages `pwd`/javadoc doc/)

# Build the installers. If you change this, then update https://kepler-project.org/users/downloads
export KEPLER_VERSION=2.6.0.1

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

# Create the jar files for the installers.
ant jar

# Build the linux and windows installers.
ant make-linux-installer -Dversion=$KEPLER_VERSION

# Under Ubuntu, need to do
#  apt-get install lib32z1 lib32ncurses5
# Otherwise, winres will report a missing file.
ant make-windows-installer -Dversion=$KEPLER_VERSION

echo "HOME: $HOME:"
ls $HOME

echo "../../finished-kepler-installers:"
ls ../../finished-kepler-installers

echo "../../finished-kepler-installers/linux:"
ls -l ../../finished-kepler-installers/linux

echo "../../finished-kepler-installers/windows:"
ls -l ../../finished-kepler-installers/windows

