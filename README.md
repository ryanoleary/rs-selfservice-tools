# Deployment to CAT

## Description

A Ruby library to convert RightScale Deployments to CAT format

## Requirements

* Ruby 1.8.7 or higher
* [Right API Client](https://github.com/rightscale/right_api_client) 1.5.15 or higher

## Usage

    ruby export_deployment.rb -d [deployment_id] -e [email] -p [password] -a [account_id]

    -d, --deployment ID              Deployment ID
    -e, --email EMAIL_ADDRESS        Email Address
    -p, --password PASSWORD          Password
    -a, --account ID                 Account ID
    -h, --help						 Show Help screen

## Details

Exports all Servers in a Deployment to CAT format using the next_instance details. Includes support for all parameters of Servers and ServerArrays (note: Subnets and SecurityGroups will only be exported when using a hacked version of RightApiClient that represents them as links due to [this bug](http://bit.ly/1f7AEZa))

## Todo

* Support for Volumes, VolumeAttachments with optional flag
* User-selectable output of inputs as parameters
* Output of other account resources as parameters (cloud, instance type, etc)