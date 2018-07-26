FROM openjdk:8-jdk
LABEL Khanh Tran <khanhtm@vng.com.vn>

ENV SDK_TOOLS "4333796"
ENV BUILD_TOOLS "27.0.3"
ENV TARGET_SDK "27"
ENV ANDROID_HOME "/opt/android-sdk-linux"
# ENV GLIBC_VERSION "2.27-r0"
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install required dependencies
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# RUN apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash && \
# 	wget https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
# 	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk && \
# 	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk && \
# 	apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
# 	rm -rf /tmp/* && \
# 	rm -rf /var/cache/apk/*

# Download and extract Android Tools
RUN wget http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS}.zip -O /tmp/tools.zip && \
	mkdir -p ${ANDROID_HOME} && \
	unzip /tmp/tools.zip -d ${ANDROID_HOME} && \
	rm -v /tmp/tools.zip

# Install SDK Packages
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
	yes | ${ANDROID_HOME}/tools/bin/sdkmanager "--licenses" && \
	${ANDROID_HOME}/tools/bin/sdkmanager "--update" && \
	${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;${BUILD_TOOLS}" "platform-tools" "platforms;android-${TARGET_SDK}" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository" "emulator"

# RVM & Ruby needed for fastlane below
RUN /bin/bash -l -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.5.1"
RUN /bin/bash -l -c "gem install psych"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Fast lane for easy apk upload to hockey app
RUN /bin/bash -l -c "gem install fastlane"