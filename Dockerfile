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

RUN apt-get install -y jq

# X11VNC
RUN apt-get install -y x11vnc
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd chimpatee ~/.vnc/passwd

RUN apt-get -y install g++ build-essential

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    apt-get update && \
    apt-get install -Vy \
    mongodb-org-tools=4.0.1 && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN npm -g config set user root
RUN npm install -g chimpy --unsafe-perm
RUN npm install -g mocha-multi-reporters --unsafe-perm
RUN npm config set unsafe-perm=true
RUN chown -R jenkins:jenkins /home/jenkins/.npm

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

WORKDIR /home/${user}
