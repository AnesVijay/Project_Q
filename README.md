# Project Q

A student project that configures a test bench of infrastructure around the ["TTG Finder" application](https://github.com/ATAS-Digital/TTGFinder) for AIOps researches.

This project creates a test bench for TTG Finder app configuring its repository in GitLab instance with already setup CI/CD and a monitoring server.

To run this project you need an account on https://yandex.cloud.

# How To Use

0. Configure parameters in `terra_yc/provider.tf` for Terraform and `ansible/gitlab/Dockerfile` for app Docker container. Also you can change GitLab project name in `ansible/vars.yml`.

1. Just run
```
./init.sh -ti -p <gitlab root password> -u <non root remote user on vm's to create and use>
```
2. Take a coffee break!

# "data-analytics"

This folder contains scripts to export metrics from Prometheus and to use them to train and test the autoencoder neural network model.
