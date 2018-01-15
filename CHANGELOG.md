# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Our CHANGELOG Guidelines ](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md).
Which is based on [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

## [0.4.1] - 2018-01-15
### Fixed
- fixed the handling of empty container metrics issue from dcos-metrics

## [0.4.0] - 2017-10-20
### Added
- todo item is added: metrics-dcos-containers.rb Add dimentions to the metric name framework_name, framework_role, executor_id (@1fox1)
- added dimensions argument, argument takes a comma seperated list of the dimensions you wish to output (@1fox1)

## [0.3.0] - 2017-09-19
### Added
- started re-testing all supported ruby versions again (@majormoses)
- kitchen converge on all tested versions in travis in a matrix fashion (@majormoses)

### Changed
- created a quick task to run all but integration and switched travis to use it. (@majormoses)

## [0.2.1] - 2017-09-12
### Added
- `check-dcos-jobs-health.rb`: checks the health of a DC/OS jobs exposed by the mesos API endpoint /tasks (@mgaitien)

## [0.1.1] - 2017-09-09
### Fixed
- metrics-dcos-system-health.rb: Small but essential fixes for DC/OS system health metrics collection (@zemmet)
- pr template spelling (@majormoses)

### Added
- automated test for metrics-dcos-system-health.rb (@zemmet)

### Changed
- test/fixtures/bootstrap.sh: run an apt-update before trying to install (@zemmet)
- updated our changelog guidelines location

## [0.1.0] - 2017-08-28
### Added
- New DC/OS node health check (@zemmet)
- New DC/OS system health metric collection script (@zemmet)

## [0.0.4] - 2017-08-12
### Added
- Rakefile now includes kitchen integration tests
- Fixes metric collection scripts to cover the cases when an app sets unit as an empty string (@luisdavim)

### [0.0.3] - 2017-08-12
### Changed
- switched from vagrant to docker testing as it's lighter weight (@majormoses)
- switched from bats to serverspec as it gives us more flexibility (@majormoses) (@luisdavim)
- upgraded rubocop and appeased it (@majormoses)
- standard `.rubocop.yml`, `CHANGELOG.md`, `Rakefile` files

### Removed
- removed various misc files from transfer such as circle-ci stuff (@majormoses)


## [0.0.2] - 2017-08-03
### Added
- New DC/OS Component Health check (@zemmet)
- Extending get_value function to provide the ability to override field names (@zemmet)

## [0.0.1] - 2017-04-18
### Added
- Initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.4.1...HEAD
[0.4.1]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.4.0...0.4.1
[0.4.0]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.1.1...0.2.1
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.4...0.1.0
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.1...0.0.2
[0.0.1]:https://github.com/sensu-plugins/sensu-plugins-dcos/compare/9c72afb596622f6c1a51f95281f52bd53791ede9...0.0.1
