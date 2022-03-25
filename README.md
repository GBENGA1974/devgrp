## Introduction

The code in this directory is to deploy a simple infrastructure.  The code is terraform, however it will deploy a "working" infrastructure.

## Requirements
To deploy this infrastructure, you will need an AWS account and also terraform installed.
Knowledge of DNS(Route53)

In this simple project, traffic is route to the loadbalancer.

Jenkinsfile is use to create a pipeline which Initializes, plan and apply terraform files.