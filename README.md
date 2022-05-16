# knife-vrealize

[![Build status](https://badge.buildkite.com/613130c62661841d0bb8ffc6c151bc9727546a8056124c627f.svg?branch=master)](https://buildkite.com/chef-oss/chef-knife-vrealize-master-verify)
[![Gem Version](https://badge.fury.io/rb/knife-vrealize.svg)](https://badge.fury.io/rb/knife-vrealize)

This is a Knife plugin that will allow you to interact with
VMware vRealize products, such as vRA and vRO, from Chef's Knife command.

Note: This version only support vRA 8.x. If you need to use this gem for vRA 7.x, try 6.0.2 or previous versions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knife-vrealize'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install knife-vrealize

... or, even better, from within Chef Workstation:

    $ chef gem install knife-vrealize

## vRealize Automation (vRA)

### Configuration

In order to communicate with vRA, you must specify your user credentials. You can specify them in your knife.rb:

```ruby
knife[:vra_username] = 'myuser'
knife[:vra_password] = 'mypassword'
knife[:vra_base_url] = 'https://vra.corp.local'
knife[:vra_tenant]   = 'mytenant'
knife[:vra_disable_ssl_verify] = true # if you want to disable SSL checking.
```

... or you can supply them on the command-line:

```
knife vra command --vra-username myuser --vra-tenant mytenant ...
```

### Usage

#### knife vra catalog list

Lists catalog items that can be used to submit machine requests.
By default, it will list all catalog items that your user has permission to see. To limit it to only items entitled entitled to a particular project, supply the `--project-id PROJECT_ID` and `--entitled` flags.

```
$ knife vra catalog list
Catalog ID                            Name                         Description                                                Source
a9cd6148-6e0b-4a80-ac47-f5255c52b43d  CentOS 6.6                   Blueprint for deploying a CentOS Linux development server  Project-1
5dcd1900-3b89-433d-8563-9606ae1249b8  CentOS 6.6 - business group  Blueprint for deploying a CentOS Linux development server  Project-2
d29efd6b-3cd6-4f8d-b1d8-da4ddd4e52b1  WindowsServer2012            Windows Server 2012 with the latest updates and patches.   Project-1
```

#### knife vra server list

Lists all machine resources that your user has permission to see. The "Deployment ID" is needed for other commands, such as `knife vra server show` and `knife vra server destroy`

```
$ knife vra server list
Deployment ID                         Name                    Status                Owner       Description
9bfe77c9-0915-47b6-8479-8627b1b24ac2  Centos 8                create_successful     admin       Centos 8 created for testing
7f586519-3644-4c4a-a9de-3eb66a987993  Windows server 2012     delete_failed         user1       Windows Server
00582a35-0365-40f1-8a47-e19579c6e5d5  Ubuntu 22.04            create_successful     admin       Test terraform
```

#### knife vra server show DEPLOYMENT_ID

Displays additional information about an individual server, such as its IP addresses.

```
$ knife vra server show 72fd5478-15f1-4aca-aa9b-012e2fa2ef01
Deployment ID: 72fd5478-15f1-4aca-aa9b-012e2fa2ef01
Deployment Name: Test terraform errors
IP Address: 10.30.237.66
Status: SUCCESS
Owner Names: admin
```

#### knife vra server create CATALOG_ID (options)

Creates a server from a catalog blueprint. Find the catalog ID with the `knife vra catalog list` command. After the resource is created, knife will attempt to bootstrap it (install chef, run chef-client for the first time, etc.).

Each blueprint may require different parameters to successfully complete provisioning. See your vRA administrator with questions. We'll do our best to give you any helpful error messages from vRA if they're available to us.

Common parameters to specify are:

 * `--image-mapping`: The image mapping that needed for this deployment which specifies the OS image for the vm
 * `--flavor-mapping`: specifies the CPU count and RAM of a VM
 * `--project-id`: Project ID also needs to be passed.
 * `--name`: Can be used to specify the name of newly created deployment. This should be unique.
 * `--version`: Specify which version of the catalog should be used for this deployment. If left blank, the latest version will be used.
 * `--ssh-password`: if a linux host, the password to use during bootstrap
 * `--winrm-password`: if a windows host, the password to use during bootstrap
 * `--image-os-type`: windows/linux
 * `--bootstrap-protocol`: winrm/ssh
 * `--server-create-timeout`: increase this if your vRa environments takes more than 10 minutes to give you a server.
 * `--bootstrap-version`: use to tie to a specific chef version if your group is not current
 * `-N`: node-name of the chef node to create. The gem will automatically create a node name with prefix `vra-` if not specified

Most of these can be set in your `knife.rb` to simplify the command:
```ruby
knife[:vra_username] = 'your-username'
knife[:vra_password] = 'your-pass'
knife[:vra_base_url] = 'https://cloud.yourcompany.com'
knife[:vra_tenant]   = 'your-tenant-name'
knife[:vra_disable_ssl_verify] = true # if you want to disable SSL checking.
knife[:subtenant_id] = 'your-subtenant-ID'
knife[:cpus] = '2'
knife[:memory] = '4096'
knife[:server_create_timeout] = '1800'
knife[:bootstrap_version] = '12.18.31' # pinning to an older version
knife[:server_url] = chef_server_url
knife[:requested_for] = 'your-username'
knife[:winrm_user] = 'machine-account-name'
knife[:winrm_password] = 'machine-account-pass'
```


```
$ knife vra server create 24026193-5863-3f72-baac-7f4cd3e1d535 --name testing-centos --project-id pro-123 \
  --image-mapping VRA-nc-lnx-ce8.0 --flavor-mapping Micro --image-os-type linux --connection-protocol ssh \
  -P password --extra-param hardware-config=string:Micro
Catalog request b1f13afe-d7c1-4647-8866-30681fc7f63d submitted.
Waiting for request to complete.
Current request status: CREATE_INPROGRESS.....................................
Catalog request complete.

Request Status: CREATE_SUCCESSFUL

Deployment ID: b1f13afe-d7c1-4647-8866-30681fc7f63d
Deployment Name: test_dep-2
IP Address: 10.30.236.21
Owner Names: admin
Bootstrapping the server by using connection_protocol: ssh and image_os_type: linux

Waiting for sshd to host (10.30.236.21)............
...
```

#### knife vra server delete DEPLOYMENT_ID

Deletes a deployment and associated resources from vRA. If you supply `--purge`, the server will also be removed from the Chef Server.

```
$ knife vra server delete 2e1f6632-1613-41d1-a07c-6137c9639609 --purge
Deployment ID: 2e1f6632-1613-41d1-a07c-6137c9639609
Deployment Name: test_dep-2
IP Address: 10.30.236.21
Status: SUCCESS
Owner Names: ${userName}

Do you really want to delete this server? (Y/N) y
Destroy request 5e390a9d-1340-489d-94be-b4eb1df98c53 submitted.
Waiting for request to complete.
Current request status: CHECKING_APPROVAL...
...
```

### Known Issue: Pagination

A bug in vRA v6 (as late as v6.2.1) causes resource/server lists to potentially return duplicate items and omit items in the returned data. This appears to be a bug in the pagination code in vRA and was initially discovered and discussed [in this GitHub issue](https://github.com/chef-partners/vmware-vra-gem/issues/10). `knife-vrealize` tries to work around this by setting a higher-than-normal page size of 200 items.  However, if you have more items in your returned data than this, you can attempt to work around this further by using:

```
--page-size NUMBER_OF_ITEMS_PER_PAGE
```


## vRealize Orchestrator (vRO)

### Configuration

In order to communicate with vRA, you must specify your user credentials. You can specify them in your knife.rb:

```ruby
knife[:vro_username] = 'myuser'
knife[:vro_password] = 'mypassword'
knife[:vro_base_url] = 'https://vra.corp.local:8281'
```

... or you can supply them on the command-line:

```
knife vro command --vro-username myuser ...
```

### Usage

### knife vro workflow execute

Executes a vRO workflow.  Requires the workflow name.  You may supply any input parameters, as well.

```
$ knife vro workflow execute "knife testing" key1=value1
Starting workflow execution...
Workflow execution 4028eece4effc046014f27da864d0187 started. Waiting for it to complete...
Workflow execution complete.

Output Parameters:
outkey1: some value (string)

Workflow Execution Log:
2015-08-13 09:17:57 -0700 info: cloudadmin: Workflow 'Knife Testing' has started
2015-08-13 09:17:58 -0700 info: cloudadmin: Workflow 'Knife Testing' has completed
```

If your workflow name is not unique in your vRO workflow list, you can specify
a specific workflow to use with `--vro-workflow-id ID`.  You can find the
workflow ID from within the vRO UI.  However, a workflow name is still required
by the API.

## Contributing

We'd love to hear from you if you find this isn't working in your VMware vRA/vRO environment. Please submit a GitHub issue with any problems you encounter.

Additionally, contributions are welcome!  If you'd like to send up any fixes or changes:

1. Fork it ( https://github.com/chef-partners/knife-vrealize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
