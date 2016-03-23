# RightScale SelfService Tools

## Description

Provides a small set of tools to help you use RS Self Service.

 - A Ruby library and command line tool to convert RightScale Deployments to CAT format
 - A command line tool to generate a human-readable list of hrefs in use in your account

## Requirements

* Ruby >= 1.9
* [Right API Client](https://github.com/rightscale/right_api_client) >= 1.5.15

## Installation

    $ gem build rs-selfservice-tools.gemspec
    # gem install rs-selfservice-tools-*.gem

It is also possible to use the scripts directly from the `bin/` folder.

## Usage

### Deployment to CAT

Export all resources in an existing deployment to a CAT file format.

`export_deployment.rb --help`
```
Usage: export_deployment [options]
    -d, --deployment ID              Deployment ID
    -e, --email EMAIL_ADDRESS        Email Address
    -p, --password PASSWORD          Password
    -a, --account ID                 Account ID
    -r, --refresh REFRESH_TOKEN      Refresh token
    -u, --url API_URL                Host to connect to
    -i, --deployment_inputs          Set inputs at the deployment level
    -c, --concurrent_launch          Set the resources to launch concurrently
    -h, --help                       Display this screen
```

Example:
```
export_deployment.rb --url 'https://us-4.rightscale.com' \
  --account 1234 \
  --refresh 'abc..123' \
  --deployment 90005600
```

### Show Cloud Hrefs

Prints a readable list of all resource hrefs for all cloud resources in an account.

`show_cloud_hrefs.rb --help`
```
Usage: show_cloud_hrefs.rb [options]
    -e, --email EMAIL_ADDRESS        Email Address
    -p, --password PASSWORD          Password
    -a, --account ID                 Account ID
    -r, --refresh REFRESH_TOKEN      Refresh token
    -u, --url API_URL                Host to connect to
    -i, --include_images             Include image hrefs (can be many)
    -h, --help                       Display this screen
```

Example:

```
show_cloud_hrefs.rb --url 'https://us-4.rightscale.com' \
  --account 1234 \
  --refresh 'abc..123'
```

Note: Subnets and SecurityGroups are not supported at this time

### Cloud Hrefs to Mappings

Prints mappings of clouds and instance_types.

`cloud_hrefs_to_mappings.rb --help`
```
Usage: cloud_hrefs_to_mappings.rb [options]
    -e, --email EMAIL_ADDRESS        Email Address
    -p, --password PASSWORD          Password
    -a, --account ID                 Account ID
    -r, --refresh REFRESH_TOKEN      Refresh token
    -u, --url API_URL                Host to connect to
    -h, --help                       Display this screen
```

Example:

```
cloud_hrefs_to_mappings.rb --url 'https://us-4.rightscale.com' \
  --account 1234 \
  --refresh 'abc..123'
```

### Convert a CloudFormation Template to CAT

`cft_to_cat.rb --help`
```
Usage: cft_to_cat.rb [options]
    -f, --file FILE_NAME             Filename of the CFT file
    -h, --help                       Display this screen
```

Example:

`cft_to_cat.rb -f contrib/cft/cloudformation-templates-us-west-1/EC2InstanceWithSecurityGroupSample.template`

## Todo

* Support for Volumes, VolumeAttachments with optional flag
* User-selectable output of inputs as parameters
* Output of other account resources as parameters (cloud, instance type, etc)
