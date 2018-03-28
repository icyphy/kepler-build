---
layout: default
---
# Ptolemy II External Access
Below are instructions for accessing the current development version of Ptolemy II, which is stored on [https://github.com/icyphy](Github)

## Other key resources:

* [Book on Ptolemy II](http://ptolemy.eecs.berkeley.edu/systems) (free download)
* [Ptolemy II main page](http://ptolemy.eecs.berkeley.edu/ptolemyII)
* [Javadoc](doc/codeDoc/) output for Java files
* [JsDoc](doc/codeDoc/js/index.html) output for Javascript
* [Travis Build](https://travis-ci.org/icyphy/ptII)
 * [Downloads](downloads/index.html)
 * [Logs](logs/index.html)
 * [Reports](reports/index.html)


# How to get Ptolemy II source code
## For the impatient

Install Java 1.8, install git and then run:

```
git clone --depth=50 --branch=master --single-branch https://github.com/icyphy/ptII
cd ptII
export PTII=`pwd`
./configure
$PTII/bin/ant
$PTII/bin/vergil
```

To develop Ptolemy II code, we recommend that you follow the  
[Ptolemy II Eclipse Instructions](http://chess.eecs.berkeley.edu/ptexternal/nightly/doc/eclipse/index.htm)

Or, see the [Ant](http://chess.eecs.berkeley.edu/ptexternal/nightly/doc/coding/ant.htm) instructions.

Windows users, Eclipse is the preferred installation method.  If you want to build with Cygwin, see</p>

* [Cygwin Instructions](http://ptolemy.eecs.berkeley.edu/ptolemyII/ptIIlatest/cygwin.htm)
* [Ptolemy II Installation Insructions](//ptolemy.eecs.berkeley.edu/ptolemyII/ptIIlatest/ptII/doc/install.htm)

## See Also
* [Summary of how to get Ptolemy II](summaryOfHowToGetPtII.html)
* [How to edit this page](edit.html)
