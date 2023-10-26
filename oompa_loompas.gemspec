require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = "oompa_loompas"
  spec.version       = OompaLoompas::VERSION
  spec.authors       = ["Matt Castle"]
  spec.email         = ["matt_castle@jabil.com"]

  spec.summary       = %q{Various helper functions for fileops, graphing, date manipulation, http handling, and general}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/MWCastle/oompa_loompas"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.2")
  spec.metadata = {
    'github_repo' => 'git@github.com:MWCastle/oompa_loompas.git'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0")
  end.filter do |f| f !~ /.gem$/ end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 2.5.2'
  spec.add_dependency 'json', '2.6.0'
  spec.add_dependency 'rubyXL', '3.4.25'
end
