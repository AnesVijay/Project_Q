FROM gitlab/gitlab-runner:latest

USER root

RUN apt update && \
apt install -y openjdk-17-jre-headless maven