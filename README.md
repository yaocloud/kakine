# Kakine

[![Build Status](https://secure.travis-ci.org/hsbt/kakine.png)](https://travis-ci.org/hsbt/kakine)

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

You can define Security Group configuration for OpenStack via YAML format. Like following syntax.

```yaml
app:
  - direction: ingress
    protocol: tcp
    port: 443
    remote_ip: 0.0.0.0/0
  - direction: ingress
    protocol: tcp
    port: 80
    remote_ip: 0.0.0.0/0
rails:
  - direction: ingress
    protocol: tcp
    port: 3000
    remote_ip: 0.0.0.0/0
```

You need to put fog configuration to home directory.

```sh
% cat ~/.fog
default:
  openstack_auth_url: "http://your-openstack-endpoint/v2.0/tokens"
  openstack_username: "admin"
  openstack_tenant: "admin"
  openstack_api_key: "admin-no-password"
```

run following command.

```sh
$ kakine show -t tenant_name # show Security Group of tenant_name
$ kaname apply -t tenant_name --dryrun # You can see all of invoke commands(dryrun)
$ kaname apply -t tenant_name # apply configuration into OpenStack
```

You can create or change Security Group on targeting tenant.

If you need to initialize your Security Gruop, you can get it via following command:

```sh
$ kaname show -t tenant_name > tenant_name.yaml
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
