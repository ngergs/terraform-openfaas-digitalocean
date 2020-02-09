# openfaas digitalocean terraform example

This is a simple example terraform project that sets up a openfaas environment using the managed kubernetes plattform provided by digitalocean.

## How to use it?
* Adjust the terraform.tfvars as you like. You have to provide your access token from digital token via the do_token variable.
* terraform init followed up by terraform apply / destroy as usual.

## What is created at digitalocean?
* One managed k8s cluster with 2-4 nodes.
* One loadbalancer.

## How to access openfaas afterwards?
Look up the ip address of the just created lb. The openfaas ui is accessible under http://ip-from-lb:8080/ui. Username is admin and the password is printed in the console after creation (this assumes linux as well as that doctl and kubectl are provided in the PATH).
