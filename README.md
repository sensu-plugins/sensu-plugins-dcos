## sensu-plugins-dcos

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-dcos.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-dcos)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-dcos.svg)](http://badge.fury.io/rb/sensu-plugins-dcos)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-dcos/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-dcos)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-dcos/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-dcos)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-dcos.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-dcos)

## Functionality

## Files
 * bin/check-dcos-component-health.rb
 * bin/check-dcos-container-count.rb
 * bin/check-dcos-container-metrics.rb
 * bin/check-dcos-jobs-health.rb
 * bin/check-dcos-metrics.rb
 * bin/check-dcos-node-health.rb
 * bin/check-dcos-ping.rb
 * bin/metrics-dcos-containers.rb
 * bin/metrics-dcos-host.rb
 * bin/metrics-dcos-system-health.rb

## Usage

### Checking Metrics

The following example checks that the count of running processes is between 150 and 300
 * a warning message will be triggered if the count is below 150 or above 300
 * a critical message will be triggered if the count is below 100 or above 350

```
check-dcos-metrics.rb -u 'http://127.0.0.1:61001/system/v1/metrics/v0/node' -m 'process.count' -w 150 -c 100 -W 300 -C 350
```

In some cases the metric name is not unique but you can filter metrics by tags using the `--filter` option followed by `TAG_NAME:TAG_VALUE`
You can also check deltas, if you pass the `-d` option the plugin will keep the previous value in a daybreak db and compare the new value against it.
```
check-dcos-metrics.rb -m 'network.in.errors' -d -f interface:docker0 -C 2 -W 1
```

Run `check-dcos-me.rb -h` for all the options.

#### Check configuration example:

This is an example how to use this plugin to ship metrics to InfluxDB using the [sensu-extensions-influxdb](https://github.com/sensu-extensions/sensu-extensions-influxdb) extension:
```
{
  "checks": {
    "dcos-host-metrics": {
      "type": "metric",
      "command": "/opt/sensu/embedded/bin/metrics-dcos-host.rb",
      "influxdb": {
        "templates": {
          "dcos\\..*\\.filesystem\\.": "source.type.measurement.field2.nil.nil.path*",
          "dcos\\..*\\.network\\.": "source.type.measurement.field2.nil.nil.interface*",
          "dcos\\.": "source.type.measurement.field*"
        },
        "tags": {
          "group": "node"
        }
      }
  }
}
```

metrics-dcos-containers.rb can be used in the same way to ship container metrics (from frameworks not apps) specify a comma seperated list of the dimensions you require in the oupput to the --dimensions flag. example metrics-dcos-containers.rb --dimensions 'framework_name,excutor_id'  


### Host Health Check

The `check-dcos-ping.rb` will return `OK` if the host reports itself as heathy or `CRITICAL` otherwize
```
check-dcos-ping.rb -h 'http://127.0.0.1:61001/system/v1/metrics/v0/ping'
```

### Jobs Health Check

The `check-dcos-jobs-health.rb` will return `OK` if the job is successfully executed for the last 15 minutes or `CRITICAL` if the tasks return FAILED or KILLED or the job is stuck take longer than (15 minutes - threshold )
```
check-dcos-jobs-health.rb -u 'http://leader.mesos:5050/tasks' -p jobname -w 1000 -t 200 
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Build
```
bundle install
bundle exec rake
bundle exec rake build
```
You'll find the gem in the `/pkg/` folder

## Notes
