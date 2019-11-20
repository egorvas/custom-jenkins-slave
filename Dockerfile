FROM jenkins/jnlp-slave:3.29-1
USER root
ENV NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    CHROME_BIN=/bin/google-chrome
RUN apt-get install -y curl \
  && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
  && apt-get install -y nodejs \
  && curl -L https://www.npmjs.com/install.sh | sh
RUN npm install
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm google-chrome-stable_current_x86_64.rpm


# METEOR
RUN curl https://install.meteor.com/ | sh


# Dependency: Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install -y google-chrome-stable libexif-dev

# Dependency: Git
RUN apt-get install -y git-core

# Dependency: xvfb (fake screen)
RUN apt-get install -y xvfb
RUN apt-get install -y zip unzip
RUN apt-get install -y jq
RUN apt-get install -y mongodb
RUN apt-get install -y gradle
RUN apt-get install -y zipalign

# X11VNC
RUN apt-get install -y x11vnc
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd chimpatee ~/.vnc/passwd

RUN apt-get -y install g++ build-essential

RUN npm -g config set user root
RUN npm install -g chimpy@0.54.0 --unsafe-perm
RUN npm install -g mocha-allure-reporter --unsafe-perm
RUN npm install -g mocha-multi-reporters --unsafe-perm
RUN npm install -g mocha-junit-reporter --unsafe-perm
RUN npm install -g truffle --unsafe-perm
RUN npm install -g sol2uml --unsafe-perm
RUN npm config set unsafe-perm=true

RUN chown -R jenkins:jenkins /home/jenkins/.npm
RUN chown -R jenkins:jenkins /home/jenkins/.meteor
RUN chown -R jenkins:jenkins /home/jenkins/.config
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

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

USER ${user}
WORKDIR /home/${user}
