# Soliloquy

Soliloquy is a Ruby structured logger gem. Soliloquy outputs JSON as the default format and custom
formatters can be written for any log format. Soliloquy includes a Railtie that
makes Rails logs more succinct by collapsing Rack and Rails request events into one line.

## Overview

Traditional web service log output, while human readable, often requires regular expressions to parse 
for machine consumption. Outside of datetime and a developer authored message there is no standard format 
for categorizing values in a particular log line.

As application deployments grow it becomes less feasible to grep logs manually. An application with a 
large pool of services will often include a log aggragator, such as Splunk, Sumo Logic, or AWS CloudWatch. 
Logs with a key/value format allow you to monitor and query a key's value without having to first parse
space or comma-delimited values. As an example, using [CloudWatch's JSON metric filters](http://docs.aws.amazon
.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html#extract-json-log-event-values) 
to find lines with slow db runtime for a particular user:

Data
```JSON
{ "path": "/user/abc123/things", "method": "GET", "status": 200, "user_id": "abc123", "db": 0.53 }
{ "path": "/user/def456/things", "method": "GET", "status": 200, "user_id": "def456", "db": 1.25 }
{ "path": "/user/abc123/things", "method": "GET", "status": 200, "user_id": "abc123", "db": 5.25 }
{ "path": "/user/abc123/things", "method": "GET", "status": 200, "user_id": "abc123", "db": 2.27 }
{ "path": "/user/abc123/things", "method": "GET", "status": 200, "user_id": "abc123", "db": 7.19 }
{ "path": "/user/def456/things", "method": "GET", "status": 200, "user_id": "def456", "db": 0.84 }
{ "path": "/user/ghi789/things", "method": "GET", "status": 200, "user_id": "ghi789", "db": 2.33 }
```

Query
```JSON
{ ($.user_id = 'abc123') && ($.db > 5.0) }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'soliloquy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install soliloquy

## Usage

	# ruby
    logger = Soliloquy::Logger.new(STDOUT)
    
    # rails
    
    # production uses default JSON formatter to standard out
    # ./config/environments/production.rb
    config.logger = Soliloquy::Logger.new(STDOUT)
    
    # don't output logs in tests ...
    # ./config/environments/test.rb
    config.logger = Soliloquy::Logger.new(nil)
    # ... but do expect to log
    # ./spec/my_spec.rb
    expect(Rails.logger).to receive(:error).with('Bad news bears', code: 500, user_id: user_factory.id).once
    
    # in development a highlighted key value formatter can be more human readable
    # ./config/environments/development.rb
    config.logger = Soliloquy::Logger.new(
      STDOUT, formatter: Soliloquy::Formatters::KeyValue, highlight: true
    )

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/department-of-veterans-affairs/soliloquy.

## License

The gem is available as open source under the terms of the Creative Commons Zero 1.0 Universal License.
