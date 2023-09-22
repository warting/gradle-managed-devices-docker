# base
FROM ubuntu:22.04
ARG TARGETARCH

## Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

## Use unicode
RUN apt-get update && apt-get -y install locales && \
    locale-gen en_US.UTF-8 || true
ENV LANG=en_US.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

RUN apt-get update \
    && \
    apt-get install --no-install-recommends -y \
    openjdk-17-jdk \
    cpu-checker  \
    wget \
    unzip \
    qemu-kvm  \
    && \
    apt-get autoclean && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


## Install Android SDK https://developer.android.com/studio
ARG sdk_version=commandlinetools-linux-9862592_latest.zip
ARG android_home=/opt/android/sdk

ARG android_build_tools=29.0.3
ARG android_ndk=false
ARG ndk_version=21.0.6113669
ARG cmake=3.10.2.4988404

RUN mkdir -p ${android_home} && \
    wget --quiet --output-document=/tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    mkdir -p "$android_home/cmdline-tools" && \
    unzip -q /tmp/${sdk_version} -d ${android_home}/cmdline-tools && \
    mv "$android_home/cmdline-tools/cmdline-tools" "$android_home/cmdline-tools/latest" && \
    rm /tmp/${sdk_version} && \
    mkdir -p /root/.android/ && touch /root/.android/repositories.cfg # vet ej varför

ENV ANDROID_HOME ${android_home}
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin

RUN yes | sdkmanager --licenses --channel=3
#
# # Emulator and Platform tools
RUN yes | sdkmanager "platform-tools" --channel=3
#
RUN sdkmanager --update --channel=3
RUN sdkmanager --list --channel=3
#
RUN yes | sdkmanager --install --channel=3 \
    "build-tools;34.0.0" \
    "platforms;android-34"

RUN yes | sdkmanager --licenses --channel=3

COPY start.sh start.sh
COPY sample-project sample-project

RUN chmod +x start.sh
RUN chmod -R +w  /opt/android/sdk
RUN chown -R docker /opt/android/sdk
RUN chmod -R +w  sample-project
RUN chown -R docker sample-project

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker
#
# # RUN echo no | avdmanager create avd --force --package "system-images;android-30;google_atd;x86" --name atddevice
# # RUN $ANDROID_HOME/emulator/emulator  -no-window @atddevice &
#
# # set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
