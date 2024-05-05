#!/bin/bash

source ch-dir.sh
cd_proj
apt update -y
apt install -y openjdk-17-jre-headless
apt install -y maven

mvn clean install -Dmaven.test.skip=true