# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "entrez/version"

Gem::Specification.new do |s|
  s.name        = "entrez"
  s.version     = Entrez::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jared Ning"]
  s.email       = ["jared@redningja.com"]
  s.homepage    = "https://github.com/ordinaryzelig/entrez"
  s.summary     = %q{HTTP requests to Entrez E-utilities}
  s.description = %q{Simple API for HTTP requests to Entrez E-utilities}
  s.license     = 'MIT'

  s.rubyforge_project = "entrez"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'httparty', '0.21.0'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'webmock', '3.18.1'
  s.add_development_dependency 'rspec', '3.12.0'
  s.add_development_dependency 'debug', '1.7.1'

end
