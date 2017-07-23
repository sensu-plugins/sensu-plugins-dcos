#!/bin/bash
#
# Set up a super simple web server and make it accept GET and POST requests
# for Sensu plugin testing.
#

set -e

source /etc/profile
DATA_DIR=/tmp/kitchen/data
RUBY_HOME=${MY_RUBY_HOME:-/opt/sensu/embedded}

# Set the locale
apt-get install locales
locale-gen en_US.UTF-8
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export LC_ALL="en_US.UTF-8"

if [[ "$RUBY_HOME" = "/opt/sensu/embedded" ]] && [[ ! -d $RUBY_HOME ]]; then
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
  echo "deb http://repositories.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
  apt-get update
  apt-get install -y sensu
else
  apt-get update
fi

apt-get install -y nginx build-essential
# service nginx status || service nginx start
rm /etc/nginx/sites-enabled/default
echo "
  server {
    listen 80;

    location /okay {
      limit_except GET {
        deny all;
      }
      return 200;
    }

    location /notthere {
      limit_except GET {
        deny all;
      }
      return 404;
    }

    location /ohno {
      limit_except GET {
        deny all;
      }
      return 500;
    }

    location /gooverthere {
       limit_except GET {
         deny all;
       }
       return 301;
    }

    location /postthingshere {
      return 200;
    }

    location /ping {
      limit_except GET {
        deny all;
      }
      return 200 '{\"ok\":true,\"timestamp\":\"2017-04-18T08:07:13Z\"}';
    }

    location /containers {
      limit_except GET {
        deny all;
      }
      return 200 '[\"f5723b09-92df-4e67-92f1-0f27268365df\",\"04E1DB2A-8902-40BF-9DFD-59A05AC74151\",\"A4CB4E86-7730-4071-BF7F-D3AE9010140D\"]';
    }

    location /containers/f5723b09-92df-4e67-92f1-0f27268365df {
      limit_except GET {
        deny all;
      }
      return 200 '{ \"datapoints\": [ { \"name\": \"cpus.throttled.time\", \"value\": 0, \"unit\": \"seconds\", \"timestamp\": \"2017-04-20T08:51:26.503431528Z\", \"tags\": { \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"executor_name\": \"Command Executor (Task: logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5) (Command: NO EXECUTABLE)\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"source\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\" } } ], \"dimensions\": { \"mesos_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-S6\", \"cluster_id\": \"244883b9-7f5a-4886-a1f8-eb5093215b3f\", \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"framework_name\": \"marathon\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"framework_role\": \"slave_public\", \"framework_principal\": \"dcos_marathon\", \"hostname\": \"10.0.3.201\" }}';
    }

    location /containers/04E1DB2A-8902-40BF-9DFD-59A05AC74151 {
      limit_except GET {
        deny all;
      }
      return 200 '{ \"datapoints\": [ { \"name\": \"cpus.throttled.time\", \"value\": 5, \"unit\": \"seconds\", \"timestamp\": \"2017-04-20T08:51:26.503431528Z\", \"tags\": { \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"executor_name\": \"Command Executor (Task: logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5) (Command: NO EXECUTABLE)\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"source\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\" } } ], \"dimensions\": { \"mesos_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-S6\", \"cluster_id\": \"244883b9-7f5a-4886-a1f8-eb5093215b3f\", \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"framework_name\": \"marathon\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"framework_role\": \"slave_public\", \"framework_principal\": \"dcos_marathon\", \"hostname\": \"10.0.3.201\" }}';
    }

    location /containers/A4CB4E86-7730-4071-BF7F-D3AE9010140D {
      limit_except GET {
        deny all;
      }
      return 200 '{ \"datapoints\": [ { \"name\": \"cpus.throttled.time\", \"value\": 10, \"unit\": \"seconds\", \"timestamp\": \"2017-04-20T08:51:26.503431528Z\", \"tags\": { \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"executor_name\": \"Command Executor (Task: logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5) (Command: NO EXECUTABLE)\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"source\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\" } } ], \"dimensions\": { \"mesos_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-S6\", \"cluster_id\": \"244883b9-7f5a-4886-a1f8-eb5093215b3f\", \"container_id\": \"5fcc5452-6e71-44b7-830f-e184a991e57f\", \"executor_id\": \"logstashpeter.7da9d387-25a6-11e7-a809-0627f25413a5\", \"framework_name\": \"marathon\", \"framework_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-0001\", \"framework_role\": \"slave_public\", \"framework_principal\": \"dcos_marathon\", \"hostname\": \"10.0.3.201\" }}';
    }

    location /node {
      limit_except GET {
        deny all;
      }
      return 200 '{\"datapoints\": [{\"name\": \"cpu.cores\",\"value\": 2,\"unit\": \"count\",\"timestamp\": \"2017-04-18T08:36:18.398311311Z\"},{\"name\": \"memory.free\",\"value\": 2721533952,\"unit\": \"bytes\",\"timestamp\": \"2017-04-18T08:36:18.399019053Z\"},{\"name\": \"network.in\",\"value\": 208,\"unit\": \"bytes\",\"timestamp\": \"2017-04-18T08:36:18.399308233Z\",\"tags\": {\"interface\": \"dummy0\"}},{\"name\": \"network.out\",\"value\": 0,\"unit\": \"bytes\",\"timestamp\": \"2017-04-18T08:36:18.399308233Z\",\"tags\": {\"interface\": \"dummy0\"}},{\"name\": \"network.in\",\"value\": 0,\"unit\": \"bytes\",\"timestamp\": \"2017-04-18T08:36:18.399308233Z\",\"tags\": {\"interface\": \"dummy1\"}},{\"name\": \"process.count\",\"value\": 208,\"unit\": \"count\",\"timestamp\": \"2017-04-18T08:36:18.415071848Z\"}],\"dimensions\": {\"mesos_id\": \"a1ac060c-82e2-4a28-bc94-c7efcbfb137d-S5\",\"cluster_id\": \"244883b9-7f5a-4886-a1f8-eb5093215b3f\",\"hostname\": \"dcos-agent\"}}';
    }

    location /system/health/units {
      limit_except GET {
        deny all;
      }
      return 200 '{\"units\":[{\"id\":\"dcos-mesos-slave-public.service\",\"name\":\"Mesos Agent Public\",\"health\":0,\"description\":\"distributed systems kernel public agent\"},{\"id\":\"dcos-log-master.socket\",\"name\":\"DC/OS Log Socket\",\"health\":0,\"description\":\"socket for DC/OS Log service\"},{\"id\":\"dcos-metrics-master.socket\",\"name\":\"DC/OS Metrics Master Socket\",\"health\":0,\"description\":\"socket for DC/OS Metrics Master service\"},{\"id\":\"dcos-3dt.socket\",\"name\":\"DC/OS Diagnostics (3DT) Agent Socket\",\"health\":0,\"description\":\"socket for DC/OS Diagnostics Agent\"}]}';
    }

    location /system/health/units/fail {
      limit_except GET {
        deny all;
      }
      return 200 '{\"units\":[{\"id\":\"dcos-mesos-slave-public.service\",\"name\":\"Mesos Agent Public\",\"health\":1,\"description\":\"distributed systems kernel public agent\"},{\"id\":\"dcos-log-master.socket\",\"name\":\"DC/OS Log Socket\",\"health\":0,\"description\":\"socket for DC/OS Log service\"},{\"id\":\"dcos-metrics-master.socket\",\"name\":\"DC/OS Metrics Master Socket\",\"health\":0,\"description\":\"socket for DC/OS Metrics Master service\"},{\"id\":\"dcos-3dt.socket\",\"name\":\"DC/OS Diagnostics (3DT) Agent Socket\",\"health\":1,\"description\":\"socket for DC/OS Diagnostics Agent\"}]}';
    }
  }
" > /etc/nginx/sites-enabled/sensu-plugins-dcos.conf
service nginx restart

cd $DATA_DIR
SIGN_GEM=false $RUBY_HOME/bin/gem build sensu-plugins-dcos.gemspec
$RUBY_HOME/bin/gem install sensu-plugins-dcos-*.gem

echo $RUBY_HOME
ls $RUBY_HOME/bin
