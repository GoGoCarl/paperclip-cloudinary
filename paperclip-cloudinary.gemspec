# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperclip/cloudinary/version'

Gem::Specification.new do |spec|
  spec.name          = "paperclip-cloudinary"
  spec.version       = Paperclip::Cloudinary::VERSION
  spec.authors       = ["Carl Scott"]
  spec.email         = ["carl.scott@solertium.com"]

  spec.summary       = %q{Store Paperclip-managed assets with Cloudinary.}
  spec.description   = %q{Store Paperclip-managed assets with Cloudinary. Requires a free Cloudinary account to get started.}
  spec.homepage      = "http://github.com/GoGoCarl/paperclip-cloudinary"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "cloudinary", "~> 1.1"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 13.0"
end
