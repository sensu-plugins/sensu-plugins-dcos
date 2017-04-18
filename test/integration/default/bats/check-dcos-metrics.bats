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
  export CHECK="$RUBY_HOME/bin/ruby $GEM_BIN/check-dcos-metrics.rb"
  export CHECK_PING="$RUBY_HOME/bin/ruby $GEM_BIN/check-dcos-ping.rb"
  export CHECK_CC="$RUBY_HOME/bin/ruby $GEM_BIN/check-dcos-container-count.rb"
  export CHECK_CM="$RUBY_HOME/bin/ruby $GEM_BIN/check-dcos-container-metrics.rb"
}

teardown() {
  export RUBY_HOME=$OLD_RUBY_HOME
  export GEM_HOME=$OLD_GEM_HOME
  export GEM_PATH=$OLD_GEM_PATH
}

@test "Check process count, OK" {
  run $CHECK -u http://localhost/node -m 'process.count' -c 50 -w 100 -C 300 -W 250
  [ $status = 0 ]
  [ "$output" = "CheckDcosApi OK: process.count = 208" ]
}

@test "Check dummy1 interface bytes in, CRITICAL" {
  run $CHECK -u http://localhost/node -m 'network.in' -f 'interface:dummy1' -c 50 -w 100 -C 300 -W 250
  [ $status = 2 ]
  [ "$output" = "CheckDcosApi CRITICAL: network.in = 0" ]
}

@test "Check ping, OK" {
  run $CHECK_PING -u http://localhost/ping
  [ $status = 0 ]
  [ "$output" = "CheckDcosPing OK: OK = true" ]
}

@test "Check container count, OK" {
  run $CHECK_CC -u http://localhost/containers -C 200 -W 150
  [ $status = 0 ]
  [ "$output" = "CheckDcosContainerCount OK: container.count = 3" ]
}

@test "Check container cpu throttle, WARNING" {
  run $CHECK_CM -u http://localhost/containers -m 'cpus.throttled.time' -d -M max -W 10 -C 20
  [ $status = 1 ]
  [ "$output" = "CheckDcosContainersApi WARNING: max cpus.throttled.time = 10 on A4CB4E86-7730-4071-BF7F-D3AE9010140D" ]
}
