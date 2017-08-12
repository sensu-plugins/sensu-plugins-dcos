# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- Rakefile now inclutes kitchen integration tests
- Fixes metric collection scripts to cover the cases when an app sets unit as ""

### [0.0.3] - 2017-08-12
### Changed
- switched from vagrant to docker testing as it's lighter weight (@majormoses)
- switched from bats to serverspec as it gives us more flexibility (@majormoses) (@luisdavim)
- upgraded rubocop and appeased it (@majormoses)
- standard `.rubocop.yml`, `CHANGELOG.md`, `Rakefile` files

### Removed
- removed various misc files from trnasfer such as circle-ci stuff (@majormoses)


## [0.0.2] - 2017-08-03
### Added
- New DC/OS Component Health check
- Extending get_value function to provide the ability to override field names

## [0.0.1] - 2017-04-18
### Added
- Initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.3...HEAD
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-dcos/compare/0.0.1...0.0.2
[0.0.1]:https://github.com/sensu-plugins/sensu-plugins-dcos/compare/9c72afb596622f6c1a51f95281f52bd53791ede9...0.0.1
