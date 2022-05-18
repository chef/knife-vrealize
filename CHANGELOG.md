# knife-vrealize changelog

<!-- latest_release 6.0.4 -->
## [v6.0.4](https://github.com/chef/knife-vrealize/tree/v6.0.4) (2022-05-18)

#### Merged Pull Requests
- INFCT-76 Updated the vmware-vra gem dependency and added support for Ruby 3.0 and 3.1 [#62](https://github.com/chef/knife-vrealize/pull/62) ([ashiqueps](https://github.com/ashiqueps))
<!-- latest_release -->

<!-- release_rollup since=6.0.2 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- INFCT-76 Updated the vmware-vra gem dependency and added support for Ruby 3.0 and 3.1 [#62](https://github.com/chef/knife-vrealize/pull/62) ([ashiqueps](https://github.com/ashiqueps)) <!-- 6.0.4 -->
- Upgrade to GitHub-native Dependabot [#55](https://github.com/chef/knife-vrealize/pull/55) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot])) <!-- 6.0.3 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v6.0.2](https://github.com/chef/knife-vrealize/tree/v6.0.2) (2020-11-25)

#### Merged Pull Requests
- Minor CI updates [#52](https://github.com/chef/knife-vrealize/pull/52) ([tas50](https://github.com/tas50))
- fix uninitialized constant Chef::Knife::Cloud::VraServerCreate::VraServiceHelpers [#54](https://github.com/chef/knife-vrealize/pull/54) ([mwrock](https://github.com/mwrock))
<!-- latest_stable_release -->

## [v6.0.0](https://github.com/chef/knife-vrealize/tree/v6.0.0) (2020-08-07)

#### Merged Pull Requests
- Handling of config values for Chef 16 and fix undefined method downcase for nil:NilClass [#51](https://github.com/chef/knife-vrealize/pull/51) ([kapilchouhan99](https://github.com/kapilchouhan99))

## [v5.0.2](https://github.com/chef/knife-vrealize/tree/v5.0.2) (2020-06-08)

#### Merged Pull Requests
- Update chefstyle requirement from ~&gt; 0.15 to ~&gt; 1.0 [#49](https://github.com/chef/knife-vrealize/pull/49) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
- Update knife-cloud requirement from &gt;= 1.2.0, &lt; 4.0 to &gt;= 1.2.0, &lt; 5.0 [#50](https://github.com/chef/knife-vrealize/pull/50) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))

## [v5.0.0](https://github.com/chef/knife-vrealize/tree/v5.0.0) (2020-04-09)

#### Merged Pull Requests
- Update chefstyle requirement from ~&gt; 0.13.3 to ~&gt; 0.14.0 [#46](https://github.com/chef/knife-vrealize/pull/46) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
- Update chefstyle requirement from ~&gt; 0.14.0 to ~&gt; 0.15.1 [#47](https://github.com/chef/knife-vrealize/pull/47) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
- Require Ruby 2.5 and allow for knife-cloud 3.x [#48](https://github.com/chef/knife-vrealize/pull/48) ([tas50](https://github.com/tas50))

## [v4.0.4](https://github.com/chef/knife-vrealize/tree/v4.0.4) (2019-12-30)

#### Merged Pull Requests
- Substitute require for require_relative [#45](https://github.com/chef/knife-vrealize/pull/45) ([tas50](https://github.com/tas50))

## [v4.0.3](https://github.com/chef/knife-vrealize/tree/v4.0.3) (2019-11-05)

#### Merged Pull Requests
- Setup for Expeditor and Buildkite [#38](https://github.com/chef-partners/knife-vrealize/pull/38) ([tas50](https://github.com/tas50))
- Switch from Rubocop to Chefstyle [#39](https://github.com/chef-partners/knife-vrealize/pull/39) ([tas50](https://github.com/tas50))
- Allow for knife-cloud 2.0 and require Ruby 2.4+ [#40](https://github.com/chef-partners/knife-vrealize/pull/40) ([tas50](https://github.com/tas50))
- Update .github content, add contributing doc, add code of conduct doc [#41](https://github.com/chef-partners/knife-vrealize/pull/41) ([tas50](https://github.com/tas50))
- Move test deps into the Gemfile and add yard [#42](https://github.com/chef/knife-vrealize/pull/42) ([tas50](https://github.com/tas50))
- Slim the install down by removing test files from the gem file [#43](https://github.com/chef/knife-vrealize/pull/43) ([tas50](https://github.com/tas50))

## [3.0.0](https://github.com/chef-partners/knife-vrealize/tree/3.0.0) (2017-09-15)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v2.1.1...3.0.0)

**Merged pull requests:**

- Removed the chef 12 dependency [\#34](https://github.com/chef-partners/knife-vrealize/pull/34) ([jjasghar](https://github.com/jjasghar))

## [v2.1.1](https://github.com/chef-partners/knife-vrealize/tree/v2.1.1) (2017-08-21)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v2.1.0...v2.1.1)

**Closed issues:**

- Driver doesn't appear to support windows yet [\#29](https://github.com/chef-partners/knife-vrealize/issues/29)
- knife\[:vra\_base\_url\] causes an error if URL has a trailing slash [\#24](https://github.com/chef-partners/knife-vrealize/issues/24)

**Merged pull requests:**

- added more useful/required parameters to readme [\#32](https://github.com/chef-partners/knife-vrealize/pull/32) ([mcascone](https://github.com/mcascone))
- Initial Jenkinsfile [\#28](https://github.com/chef-partners/knife-vrealize/pull/28) ([jjasghar](https://github.com/jjasghar))
- Fixes \#24 [\#27](https://github.com/chef-partners/knife-vrealize/pull/27) ([jjasghar](https://github.com/jjasghar))
- Updating travis and new versions of ruby [\#26](https://github.com/chef-partners/knife-vrealize/pull/26) ([jjasghar](https://github.com/jjasghar))

## [v2.1.0](https://github.com/chef-partners/knife-vrealize/tree/v2.1.0) (2017-02-09)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v2.0.1...v2.1.0)

**Merged pull requests:**

- 2.1.0 release [\#23](https://github.com/chef-partners/knife-vrealize/pull/23) ([jjasghar](https://github.com/jjasghar))
- Added ssl-mode verify [\#22](https://github.com/chef-partners/knife-vrealize/pull/22) ([jjasghar](https://github.com/jjasghar))

## [v2.0.1](https://github.com/chef-partners/knife-vrealize/tree/v2.0.1) (2017-01-10)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v2.0.0...v2.0.1)

**Merged pull requests:**

- Add --vra-tenant command line option [\#21](https://github.com/chef-partners/knife-vrealize/pull/21) ([bdiringer](https://github.com/bdiringer))

## [v2.0.0](https://github.com/chef-partners/knife-vrealize/tree/v2.0.0) (2016-12-15)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.5.0...v2.0.0)

**Closed issues:**

- certificate verify failure [\#16](https://github.com/chef-partners/knife-vrealize/issues/16)

**Merged pull requests:**

- v1.5.1 [\#18](https://github.com/chef-partners/knife-vrealize/pull/18) ([jjasghar](https://github.com/jjasghar))

## [v1.5.0](https://github.com/chef-partners/knife-vrealize/tree/v1.5.0) (2016-08-02)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.4.0...v1.5.0)

**Closed issues:**

- Provide a --noboostrap option [\#15](https://github.com/chef-partners/knife-vrealize/issues/15)
- Prompt for password if not supplied [\#14](https://github.com/chef-partners/knife-vrealize/issues/14)
- Can't create new servers [\#13](https://github.com/chef-partners/knife-vrealize/issues/13)
- --extra-param option continually failing with Unknown field error [\#11](https://github.com/chef-partners/knife-vrealize/issues/11)

**Merged pull requests:**

- bumped vra gem [\#17](https://github.com/chef-partners/knife-vrealize/pull/17) ([jjasghar](https://github.com/jjasghar))
- fixing travis notifications [\#12](https://github.com/chef-partners/knife-vrealize/pull/12) ([adamleff](https://github.com/adamleff))

## [v1.4.0](https://github.com/chef-partners/knife-vrealize/tree/v1.4.0) (2015-10-30)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.3.1...v1.4.0)

**Merged pull requests:**

- Adding logic to fall back to the vRA resource/server name [\#10](https://github.com/chef-partners/knife-vrealize/pull/10) ([adamleff](https://github.com/adamleff))

## [v1.3.1](https://github.com/chef-partners/knife-vrealize/tree/v1.3.1) (2015-10-29)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.3.0...v1.3.1)

**Merged pull requests:**

- Bug-fix for handling extra parameters [\#9](https://github.com/chef-partners/knife-vrealize/pull/9) ([adamleff](https://github.com/adamleff))

## [v1.3.0](https://github.com/chef-partners/knife-vrealize/tree/v1.3.0) (2015-10-26)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.2.0...v1.3.0)

**Merged pull requests:**

- Added pagination size option and a higher-than-normal default. [\#8](https://github.com/chef-partners/knife-vrealize/pull/8) ([adamleff](https://github.com/adamleff))
- Correct homepage in gemspec [\#7](https://github.com/chef-partners/knife-vrealize/pull/7) ([philoserf](https://github.com/philoserf))

## [v1.2.0](https://github.com/chef-partners/knife-vrealize/tree/v1.2.0) (2015-09-17)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.1.0...v1.2.0)

**Merged pull requests:**

- Enable `--server-create-timeout` option [\#6](https://github.com/chef-partners/knife-vrealize/pull/6) ([afiune](https://github.com/afiune))

## [v1.1.0](https://github.com/chef-partners/knife-vrealize/tree/v1.1.0) (2015-08-14)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.0.0...v1.1.0)

**Merged pull requests:**

- New "vro workflow execute" command [\#5](https://github.com/chef-partners/knife-vrealize/pull/5) ([adamleff](https://github.com/adamleff))
- remove release candidate restriction from vmware-vra, add changelog [\#4](https://github.com/chef-partners/knife-vrealize/pull/4) ([adamleff](https://github.com/adamleff))
- changing from 2-spaces-after-period to 1 space [\#3](https://github.com/chef-partners/knife-vrealize/pull/3) ([adamleff](https://github.com/adamleff))

## [v1.0.0](https://github.com/chef-partners/knife-vrealize/tree/v1.0.0) (2015-08-07)
[Full Changelog](https://github.com/chef-partners/knife-vrealize/compare/v1.0.0.rc1...v1.0.0)

**Merged pull requests:**

- Release v1.0.0 [\#2](https://github.com/chef-partners/knife-vrealize/pull/2) ([adamleff](https://github.com/adamleff))

## [v1.0.0.rc1](https://github.com/chef-partners/knife-vrealize/tree/v1.0.0.rc1) (2015-07-30)
**Merged pull requests:**

- Initial release of the knife-vrealize plugin [\#1](https://github.com/chef-partners/knife-vrealize/pull/1) ([adamleff](https://github.com/adamleff))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*