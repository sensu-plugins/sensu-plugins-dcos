#!/usr/bin/env bats

setup() {
  export OLD_RUBY_HOME=$RUBY_HOME
  export OLD_GEM_HOME=$GEM_HOME
  export OLD_GEM_PATH=$GEM_PATH

  unset GEM_HOME
  unset GEM_PATH
  source /etc/profile
  export RUBY_HOME=${MY_RUBY_HOME:-/opt/sensu/embedded}

  INNER_GEM_HOME=$($RUBY_HOME/bin/ruby -e 'print ENV["GEM_HOME"]')
  [ -n "$INNER_GEM_HOME" ] && GEM_BIN=$INNER_GEM_HOME/bin || GEM_BIN=$RUBY_HOME/bin
  export CHECK="$RUBY_HOME/bin/ruby $GEM_BIN/check-dcos-component-health.rb"
}

teardown() {
  export RUBY_HOME=$OLD_RUBY_HOME
  export GEM_HOME=$OLD_GEM_HOME
  export GEM_PATH=$OLD_GEM_PATH
}

@test "Check failed components, OK" {
  run $CHECK -u http://localhost/system/health/units
  [ $status = 0 ]
  [ "$output" = "CheckDcosComponentHealth OK: components.unhealthy = 0" ]
}

@test "Check failed components, CRITICAL" {
  run $CHECK -u http://localhost/system/health/units/fail
  [ $status = 2 ]
  [ "$output" = "CheckDcosComponentHealth CRITICAL: components.unhealthy = 2" ]
}

@test "Check service health, OK" {
  run $CHECK -u http://localhost/system/health/units -c 'dcos-mesos-slave-public.service'
  [ $status = 0 ]
  [ "$output" = "CheckDcosComponentHealth OK: dcos-mesos-slave-public.service = 0" ]
}

@test "Check service health, CRITICAL" {
  run $CHECK -u http://localhost/system/health/units/fail -c 'dcos-mesos-slave-public.service'
  [ $status = 2 ]
  [ "$output" = "CheckDcosComponentHealth CRITICAL: dcos-mesos-slave-public.service = 1" ]
}
