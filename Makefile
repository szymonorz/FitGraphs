IOS_VERSION=16.4
PLATFORM=iOS Simulator
EMULATOR_NAME=iPhone SE (3rd generation)
CURRENT_DIR:=${CURDIR}
XCODE_FLAGS=-scheme DataMobileUI -allowProvisioningUpdates SYMROOT='./build'
APP_PATH=${CURRENT_DIR}/build/Debug-iphonesimulator/DataMobileUI.app
IOS_BUNDLE_ID=pl.szyorz.DataMobileUI
SRC = $(shell find . -name "*.swift")

.PHONY: all clean install build


all: install boot
	xcrun simctl launch booted $(IOS_BUNDLE_ID)

install: build
	xcrun simctl install booted $(APP_PATH)

build: $(SRC)
    # echo $(SRC)
	xcodebuild -destination "platform=$(PLATFORM),name=$(EMULATOR_NAME),OS=$(IOS_VERSION)" $(XCODE_FLAGS) build

clean:
	rm -rf build boot

boot:
	xcrun simctl boot "${EMULATOR_NAME}"
	open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
	echo 1 > ${CURRENT_DIR}/boot
