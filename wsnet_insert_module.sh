#!/usr/bin/env bash

if [ $# -le 1 ]
then
        echo "usage: $0 library name "
        echo "       library can be: propagation"
        echo "                       interferences"
        echo "                       modulation"
        echo "                       antenna"
        echo "                       mobility"
        echo "                       energy"
        echo "                       environment"
        echo "                       monitor"
        echo "                       radio"
        echo "                       mac"
        echo "                       routing"
        echo "                       application"
        exit 0
fi

pushd .

if test $# -lt 2 ; then
  echo missing argument for module name and/or type
  exit 1
fi

while test $# -ne 0; do
type=`basename $1 | cut -d. -f1`
shift
moduleName=`basename $1 | cut -d. -f1`
shift

cd $HOME/too/wsnet-module/user_models/$moduleName

if [ -f $HOME/too/wsnet-module/user_models/$moduleName/Makefile.am ]; then
  echo "do not run configure..."
  echo "do not run bootstrap..."
else            
  echo Editing $PWD/Makefile.am
  echo lib_LTLIBRARIES = lib${type}_${moduleName}.la > Makefile.am
  echo lib${type}_${moduleName}_la_CFLAGS = "\$(CFLAGS) \$(GLIB_FLAGS) " -Wall >> Makefile.am
  echo lib${type}_${moduleName}_la_SOURCES = ${moduleName}.c >> Makefile.am
  echo lib${type}_${moduleName}_la_LDFLAGS = -module >> Makefile.am
  libtoolize --copy --force
  ./bootstrap
  ./configure --prefix=$HOME/too/wsnet-module \
            --libdir=$HOME/too/wsnet-module/lib \
            --with-wsnet-dir=/usr/local/wsnet-2.0
fi
            

echo compiling module $moduleName

make
make install

done
popd

