Bootstrap: docker
From: ubuntu:16.04

%environment
      HOME=/home
      D4J_HOME=/home/naturalbugpatch/defects4j
      SCRIPTS=/home/naturalbugpatch/GenProgScripts
      export HOME D4J_HOME SCRIPTS

%post
      apt-get update && apt-get install -y software-properties-common
      add-apt-repository -y ppa:openjdk-r/ppa
      apt-get update
      apt-get install -y openjdk-7-jdk openjdk-8-jdk openjdk-9-jdk git subversion make gcc wget vim maven zip
      git clone https://github.com/tonyswoo/naturalbugpatch.git /home/naturalbugpatch
      /home/naturalbugpatch/initialize.sh
      mkdir /home/naturalbugpatch/defects4j/D4JwithGP
      chown nobody:nogroup -R /home
