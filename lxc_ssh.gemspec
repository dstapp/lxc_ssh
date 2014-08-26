# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lxc_ssh/version'

Gem::Specification.new do |spec|
  spec.name          = "lxc_ssh"
  spec.version       = LxcSsh::VERSION
  spec.authors       = ["David Prandzioch"]
  spec.email         = ["david@backport.net"]
  spec.summary       = %q{LXC CLI wrapper using SSH}
  spec.description   = %q{lxc_ssh is a ruby gem for managing lxc host systems over an ssh connection. Supports LXC version 1.0 and higher. Depends on net-ssh.}
  spec.homepage      = "https://github.com/dprandzioch/lxc_ssh"
  spec.license       = "GPL-2.0"

  #spec.files         = `git ls-files -z`.split("\x0")
  spec.files         = Dir["README.md","Gemfile","Rakefile", "lib/**/*"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "net-ssh", "~> 2.9"
end
