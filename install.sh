#! /bin/sh

PREFIX='/usr/local'
SWIFT_BUILD_FLAGS="--disable-sandbox -c release"
BUILD_DIR=$(swift build $SWIFT_BUILD_FLAGS --show-bin-path)

if [ -d "${PREFIX}/bin/grain-build" ]; then
  # Take action if $DIR exists. #
  rm -rf ${PREFIX}/bin/grain-build
fi

swift build $SWIFT_BUILD_FLAGS 
mkdir -p ${PREFIX}/bin/grain-build
cp -f ${BUILD_DIR}/grain ${PREFIX}/bin/grain-build/
cp -f ${BUILD_DIR}/libSwiftToolsSupport.dylib ${PREFIX}/bin/grain-build/
cp -f ${BUILD_DIR}/libGrainDescriptor.dylib ${PREFIX}/bin/grain-build/
ln -f -s ${PREFIX}/bin/grain-build/grain ${PREFIX}/bin/grain