#!/bin/bash

# $ANDROID_SDK_ROOT/emulator/emulator  -no-window @atddevice &
# adb wait-for-device


#adb devices

echo "Starting..."

kvm-ok
cd sample-project
./gradlew pixel2api30DebugAndroidTest \
--no-daemon --no-parallel --max-workers=1 \
-Dorg.gradle.workers.max=1 \
-Pandroid.testoptions.manageddevices.emulator.gpu=swiftshader_indirect \
-Pandroid.experimental.testOptions.managedDevices.setupTimeoutMinutes=180 \
-Pandroid.experimental.androidTest.numManagedDeviceShards=1 \
-Pandroid.experimental.testOptions.managedDevices.maxConcurrentDevices=1 \
-Pandroid.experimental.testOptions.managedDevices.emulator.showKernelLogging=false \
--stacktrace