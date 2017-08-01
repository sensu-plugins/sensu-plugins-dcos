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

@test "Check process count, OK" {
  run $CHECK -u http://localhost/units
  [ $status = 0 ]
  [ "$output" = "CheckDcosComponentHealth OK" ]
}

@test "Check dummy1 interface bytes in, CRITICAL" {
  run $CHECK -u http://localhost/units -c 'dcos-mesos-dns.service'
  [ $status = 0 ]
  [ "$output" = "CheckDcosComponentHealth OK: dcos-mesos-dns.service is healthy" ]
}
