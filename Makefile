PLATFORMSROOT=/Applications/Xcode.app/Contents/Developer/Platforms
SIMULATORROOT=$(PLATFORMSROOT)/iPhoneSimulator.platform/Developer
DEVICEROOT=$(PLATFORMSROOT)/iPhoneOS.platform/Developer
IOSVERSION=$(shell defaults read $(PLATFORMSROOT)/iPhoneOS.platform/version CFBundleShortVersionString)
SIMULATOR_SDK=$(SIMULATORROOT)/SDKs/iPhoneSimulator$(IOSVERSION).sdk
DEVICE_SDK=$(DEVICEROOT)/SDKs/iPhoneOS$(IOSVERSION).sdk

CFLAGS=-stdlib=libc++ -DHAVE_CONFIG_H -DOS_MACOSX -I. -O2
SIMULATOR_CFLAGS=$(CFLAGS) -isysroot $(SIMULATOR_SDK) -arch i386 -arch x86_64
DEVICE_CFLAGS=$(CFLAGS) -isysroot $(DEVICE_SDK) -arch armv6 -arch armv7 -arch arm64

OBJECTS = $(patsubst %.cc, %.o, $(wildcard *.cc))

all: $(OBJECTS)
	rm -f libsnappy.a
	#ar -cru libsnappy.a $(OBJECTS)
	ar -rs libsnappy.a $(OBJECTS)

.cc.o:
	mkdir -p ios-x86
	mkdir -p ios-arm
	$(CXX) $(SIMULATOR_CFLAGS) -c $< -o ios-x86/$@
	xcrun -sdk iphoneos $(CXX) $(DEVICE_CFLAGS) -c $< -o ios-arm/$@
	lipo ios-x86/$@ ios-arm/$@ -create -output $@

clean:
	rm -rf *.o *.a ios-x86 ios-arm

