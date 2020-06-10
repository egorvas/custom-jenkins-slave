FROM jenkins/jnlp-slave:3.40-1 as main
USER root
ENV NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

RUN apt-get install -y curl \
  && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
  && apt-get install -y nodejs \
  && curl -L https://www.npmjs.com/install.sh | sh \
  && npm -g config set user root

# INSTALL MAIN DEPS
RUN apt update \
  && apt-get install -y git-core zip unzip jq gradle zipalign g++ build-essential mongodb

# INSTALL NPM DEPS
RUN npm install -g chimpy@0.54.0 --unsafe-perm \
  && npm install -g mocha-allure-reporter --unsafe-perm \
  && npm install -g mocha-multi-reporters --unsafe-perm \
  && npm install -g mocha-junit-reporter --unsafe-perm \
  && npm install -g truffle --unsafe-perm \
  && npm install -g sol2uml --unsafe-perm \
  && npm config set unsafe-perm=true

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
USER ${user}
WORKDIR /home/${user}


FROM main AS meteor
# METEOR
RUN curl https://install.meteor.com/ | sh


FROM meteor AS android
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
