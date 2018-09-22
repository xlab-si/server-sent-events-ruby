lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "server_sent_events/version"

Gem::Specification.new do |spec|
  spec.name          = "server_sent_events"
  spec.version       = ServerSentEvents::VERSION
  spec.authors       = ["Tadej Borovšak"]
  spec.email         = ["tadej.borovsak@xlab.si"]

  spec.summary       = "Library for dealing with server-sent events"
  spec.homepage      = "https://github.com/xlab-si/server-sent-events-ruby"
  spec.license       = "Apache-2.0"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.59.1"
  spec.add_development_dependency "simplecov", "~> 0.10.2"
  spec.add_development_dependency "yard", "~> 0.9.16"
end
