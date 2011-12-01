# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-arduino"
  s.version     = "0.0.1" 
  s.authors     = ["toddtreece"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Siri controller for an arduino universal remote}
  s.description = %q{Controlls a Phillips TV, Comcast cable box and Apple TV}

  s.rubyforge_project = "siriproxy-arduino"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "json"
end

