# LICENCE:
#    PTC http://www.ptc.com/
#    Copyright 2017 PTC Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Common
  def initialize
    super()
  end

  def get_data(url)
    url = URI.parse(url)
    response = Net::HTTP.get_response(url)
    if response.code == '204'
      return {}
    end
    JSON.parse(response.body)
  rescue Errno::ECONNREFUSED
    warning 'Connection refused'
  rescue JSON::ParserError
    critical 'Invalid JSON'
  end

  def get_value(url, metric, filter, name_field = 'name', value_field = 'value', root_field = 'datapoints') # rubocop:disable Metrics/ParameterLists
    resource = get_data(url)
    return {} if resource.nil? || resource.empty?
    if filter
      filter = filter.split(':')
      value = resource[root_field].select { |data| data['tags'] == { filter[0] => filter[1] } }
      value.select { |data| data[name_field] == metric }.first[value_field]
    else
      resource[root_field].select { |data| data[name_field] == metric }.first[value_field]
    end
  end
end
