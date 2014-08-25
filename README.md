# lxc_ssh

lxc_ssh is a ruby gem for managing lxc host systems over an ssh connection.
Supports LXC version 1.0 and higher. Depends on net-ssh (https://github.com/net-ssh/net-ssh).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lxc_ssh'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lxc_ssh

## Usage

First create a connection to your system over ssh (currently only the ssh default port is supported)
and authenticate as a privileged user (lxc is installed to /usr in this case):

```ruby
con = LxcSsh::Connection.new
con.connect('my.cool.host', 'root', nil, '/usr')
```

If no exception occured, you're ready to go.

#### Get containers

```ruby
containers = con.manager.containers
```


#### Get specific container information

```ruby
container = con.manager.container 'my-fancy-container-name'
```

Result:

```ruby
#<LxcSsh::Container:0x00000000c7ea48 @name="my-fancy-container-name",
                                     @pid="1234",
                                     @state="RUNNING",
                                     @memory_usage=0,
                                     @memory_limit=0,
                                     @cpu_shares=1024,
                                     @cpu_usage="23994168167209",
                                     @ip="192.168.0.2">
```

#### Get container config

```ruby
config = con.manager.container_config 'my-fancy-container-name'
puts config['lxc.network.veth.pair']
```


#### Update config items

```ruby
config = con.manager.container_config 'my-fancy-container-name'
config['lxc.network.veth.pair'] = 'none'
con.manager.write_config 'my-fancy-container-name', config
```

### Create container

```ruby
con.manager.create_container 'testcontainer', 'gentoo'
```

#### Start container

```ruby
con.manager.start_container 'testcontainer'
```

#### Stop container

```ruby
con.manager.stop_container 'testcontainer'
```

#### Destroy container

```ruby
con.manager.destroy_container 'testcontainer'
```

#### Create container

```ruby
con.manager.create_container 'testcontainer', 'gentoo'
```

#### Get templates

```ruby
con.manager.template_names
```

#### Get template help text

```ruby
puts con.manager.template_help 'archlinux'
```

## Contributing

1. Fork it ( https://github.com/dprandzioch/lxc_ssh/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request