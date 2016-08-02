# knife-vrealize Change Log

## Release: v1.5.1
 * Rubcop for the rubocop gods.

## Release: v1.5.0
 * Bumped the vra-gem per issues with [SSL](https://github.com/chef-partners/vmware-vra-gem/pull/31)

## Release: v1.4.0
 * [pr#10](https://github.com/chef-partners/knife-vrealize/pull/10) Added logic to prefer the IP address if it's available, but fallback to the rsource record / server name if it's not.

## Release: v1.3.1
 * [pr#9](https://github.com/chef-partners/knife-vrealize/pull/9) Bug fix for handling of extra parameters, which were never properly sent to the vRA API

## Release: v1.3.0
 * [pr#8](https://github.com/chef-partners/knife-vrealize/pull/8) Allow configuration of pagination result set size to work around known vRA pagination bug.

## Release: v1.2.0
 * [pr#6](https://github.com/chef-partners/knife-vrealize/pull/6) Fixing issue with --server-create-timeout not being honored

## Release: v1.1.0
 * new "vro workflow execute" command to allow arbitrary workflow executions via knife

## Release: v1.0.1
 * remove release-candidate restriction from the version pin for the vmware-vra gem

## Release: v1.0.0
 * Initial release with support for vRA
