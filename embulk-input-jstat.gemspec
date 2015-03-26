# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "embulk-input-jstat"
  spec.version       = "0.0.3"
  spec.authors       = ["KUBOTA Yuji"]
  spec.email         = ["kubota.yuji@gmail.com"]
  spec.summary       = %q{Embulk plugin for jstat input.}
  spec.description   = %q{Embulk input plugin for Java Virtual Machine statistics by jstat command.}
  spec.homepage      = "https://github.com/ykubota/embulk-input-jstat"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
