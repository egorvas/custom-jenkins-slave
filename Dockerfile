FROM jenkins/inbound-agent:4.3-4 as main
USER root
ENV NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    CHROME_BIN=/bin/google-chrome

RUN apt-get install -y curl \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs \
  && curl -L https://www.npmjs.com/install.sh | sh \
  && npm update \
  && npm config set unsafe-perm=true \
  && npm -g config set user root

# INSTALL MAIN DEPS
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
  && echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org.list \
  && apt update \
  && apt-get install -y git-core zip unzip jq mongodb-org-shell mongodb-org-tools gradle zipalign g++ build-essential libkrb5-dev

# INSTALL NPM DEPS
RUN npm install --unsafe-perm node-sass -g \
  && npm install -g chimpy@0.54.0 --unsafe-perm=true \
  && npm install -g mocha-allure-reporter --unsafe-perm=true \
  && npm install -g mocha-multi-reporters --unsafe-perm=true \
  && npm install -g mocha-junit-reporter --unsafe-perm=true \
  && npm install -g truffle --unsafe-perm=true \
  && npm install -g sol2uml --unsafe-perm=true \
  && chown -R jenkins:jenkins /home/jenkins/.npm \
  && chown -R jenkins:jenkins /home/jenkins/.config

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
USER ${user}
WORKDIR /home/${user}


FROM main AS meteor
# Dependency: Google Chrome
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm google-chrome-stable_current_x86_64.rpm
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable libexif-dev

# METEOR
RUN curl https://install.meteor.com/ | sh \
  && chown -R jenkins:jenkins /home/jenkins/.meteor



FROM meteor AS android
# X11VNC
RUN apt-get install -y xvfb x11vnc \
  && mkdir ~/.vnc \
  && x11vnc -storepasswd chimpatee ~/.vnc/passwd

ENV ANDROID_HOME /home/jenkins/sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# For running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

RUN mkdir -p $ANDROID_HOME

# Android SDK Tools 26.1.1
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O /opt/tools.zip \
	&& unzip /opt/tools.zip -d $ANDROID_HOME \
	&& rm -f /opt/tools.zip

RUN yes | sdkmanager 'build-tools;26.0.2' 'extras;google;m2repository' 'platform-tools' 'platforms;android-26' 'tools'
RUN chown -R jenkins:jenkins /home/jenkins/sdk
