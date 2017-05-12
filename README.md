# Kakine

[![Build Status](https://travis-ci.org/yaocloud/kakine.svg?branch=master)](https://travis-ci.org/yaocloud/kakine)

Kakine(垣根) is configuration management tool of Security Group on OpenStack.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kakine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kakine

## Usage

### Syntax

You can define Security Group configuration for OpenStack in YAML format as the following example.

```yaml
app:
  rules:
    - direction: ingress
      protocol: tcp
      port: 443
      remote_ip: 0.0.0.0/0
    - direction: ingress
      protocol: tcp
      port: 80
      remote_ip: 0.0.0.0/0
  description: app rules
rails:
  rules:
    - direction: ingress
      protocol: tcp
      port: 3000
      remote_ip: 0.0.0.0/0
```

`port`s and `remote_ip`s may be specified as arrays, in which case the rule is expanded to set of rules with all the combinations of them.
```yaml
app:
  rules:
    - direction: ingress
      protocol: tcp
      port: [80, 443]
      remote_ip:
        - 192.0.2.0/24
        - 198.51.100.0/24
```


Top-level keys whose name both starts and ends with underscores (eg. `_common_`, `_default_`) are considered **meta sections** and do not correspond to security groups.
These sections are useful to define values that commonly appears throughout the file, used with YAML's anchors and references.

```yaml
_common_:
  - &net1 192.0.2.0/24
  - &net2 198.51.100.0/24

restricted_web:
  rules:
  - direction: ingress
    protocol: tcp
    port: 80
    remote_ip: *net1
  - direction: ingress
    protocol: tcp
    port: 80
    remote_ip: *net2
  description: Restricted HTTP access
```

### Authentication configuration

You need to put a configuration file to home directory.

```sh
% cat ~/.kakine
auth_url: "http://your-openstack-endpoint/v2.0"
username: "admin"
password: "admin"
```

also, you can set some options.

```
client_cert: "/path/to/cert.pem"
client_key: "/path/to/key.pem"
region_name: "YourRegion"
```

### Commands

run following command.

```sh
$ kakine show -t tenant_name # show Security Group of tenant_name
$ kakine apply -t tenant_name --dryrun # You can see all of invoke commands(dryrun)
$ kakine apply -t tenant_name # apply configuration into OpenStack
```

You can create or change Security Group on targeting tenant.

If you need to initialize your Security Gruop, you can get it via following command:

```sh
$ kakine show -t tenant_name > tenant_name.yaml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/hsbt/kakine/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
