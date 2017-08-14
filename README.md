# knife-vrealize

This is a Knife plugin that will allow you to interact with
VMware vRealize products, such as vRA and vRO, from Chef's Knife command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knife-vrealize'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install knife-vrealize

... or, even better, from within ChefDK:

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

Lists catalog items that can be used to submit machine requests. By default, it will list all catalog items that your user has permission to see. To limit it to only items to which you are entitled, supply the `--entitled` flag.

```
$ knife vra catalog list
Catalog ID                            Name                         Description                                                Status     Subtenant
a9cd6148-6e0b-4a80-ac47-f5255c52b43d  CentOS 6.6                   Blueprint for deploying a CentOS Linux development server  published
5dcd1900-3b89-433d-8563-9606ae1249b8  CentOS 6.6 - business group  Blueprint for deploying a CentOS Linux development server  published  Rainpole Developers
d29efd6b-3cd6-4f8d-b1d8-da4ddd4e52b1  WindowsServer2012            Windows Server 2012 with the latest updates and patches.   published
```

#### knife vra server list

Lists all machine resources that your user has permission to see. The "resource ID" is needed for other commands, such as `knife vra server show` and `knife vra server destroy`

```
$ knife vra server list
Resource ID                           Name        Status  Catalog Name
2e1f6632-1613-41d1-a07c-6137c9639609  hol-dev-43  active  CentOS 6.6
43898686-7395-468a-99b3-b0b18a8abc1b  hol-dev-44  active  CentOS 6.6
0977f98b-d927-4e71-8b5b-b27c7deda097  hol-dev-45  active  CentOS 6.6
```

#### knife vra server show RESOURCE_ID

Displays additional information about an individual server, such as its IP addresses.

```
$ knife vra server show 2e1f6632-1613-41d1-a07c-6137c9639609
Server ID: 2e1f6632-1613-41d1-a07c-6137c9639609
Server Name: hol-dev-43
IP Addresses: 192.168.110.203
Status: ACTIVE
Catalog Name: CentOS 6.6
```

#### knife vra server create CATALOG_ID (options)

Creates a server from a catalog blueprint. Find the catalog ID with the `knife vra catalog list` command. After the resource is created, knife will attempt to bootstrap it (install chef, run chef-client for the first time, etc.).

Each blueprint may require different parameters to successfully complete provisioning. See your vRA administrator with questions. We'll do our best to give you any helpful error messages from vRA if they're available to us.

Common parameters to specify are:

 * `--cpus`: number of CPUs
 * `--memory`: amount of RAM in MB
 * `--requested-for`: vRA login that should be listed as the owner
 * `--lease-days`: number of days for the resource lease
 * `--notes`: any optional notes you'd like to be logged with your request
 * `--subtenant-id`: all resources must be tied back to a Business Group, or "subtenant." If your catalog item is tied to a specific Business Group, you do not need to specify this. However, if your catalog item is a global catalog item, then the subtenant ID is not available to us; you will need to provide it. It usually looks like a UUID. See your vRA administrator for assistance in determining your subtenant ID.
 * `--ssh-password`: if a linux host, the password to use during bootstrap
 * `--winrm-password`: if a windows host, the password to use during bootstrap
 * `--image-os-type`: windows/linux
 * `--bootstrap-protocol`: winrm/ssh

```
$ knife vra server create 5dcd1900-3b89-433d-8563-9606ae1249b8 --cpus 1 --memory 512 --requested-for devmgr@corp.local --ssh-password 'mypassword' --lease-days 5
Catalog request d282fde8-6fd2-406c-998e-328d1b659078 submitted.
Waiting for request to complete.
Current request status: PENDING_PRE_APPROVAL.
Current request status: IN_PROGRESS..
...
```

#### knife vra server delete RESOURCE_ID

Deletes a server from vRA. If you supply `--purge`, the server will also be removed from the Chef Server.

```
$ knife vra server delete 2e1f6632-1613-41d1-a07c-6137c9639609 --purge
Server ID: 2e1f6632-1613-41d1-a07c-6137c9639609
Server Name: hol-dev-43
IP Addresses: 192.168.110.203
Status: ACTIVE
Catalog Name: CentOS 6.6

Do you really want to delete this server? (Y/N) Y
Destroy request f2aa716b-ab24-4232-ac4a-07635a03b4d4 submitted.
Waiting for request to complete.
Current request status: PENDING_PRE_APPROVAL.
Current request status: IN_PROGRESS...
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
