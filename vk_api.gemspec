# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vk_api"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nikolay Karev", "Nick Recobra"]
  s.date = "2013-05-23"
  s.description = "\u{413}\u{435}\u{43c} \u{434}\u{43b}\u{44f} \u{43e}\u{431}\u{449}\u{435}\u{43d}\u{438}\u{44f} \u{441} Open API \u{441}\u{430}\u{439}\u{442}\u{430} \u{412}\u{41a}\u{43e}\u{43d}\u{442}\u{430}\u{43a}\u{442}\u{435} \u{431}\u{435}\u{437} \u{438}\u{441}\u{43f}\u{43e}\u{43b}\u{44c}\u{437}\u{43e}\u{432}\u{430}\u{43d}\u{438}\u{44f} \u{43f}\u{43e}\u{43b}\u{44c}\u{437}\u{43e}\u{432}\u{430}\u{442}\u{435}\u{43b}\u{44c}\u{441}\u{43a}\u{438}\u{445} \u{441}\u{435}\u{441}\u{441}\u{438}\u{439}."
  s.email = ["oruenu@gmail.com"]
  s.files = [".gitignore", "Gemfile", "README.rdoc", "Rakefile", "lib/vk_api.rb", "lib/vk_api/session.rb", "lib/vk_api/version.rb", "test/test_helper.rb", "test/vk_api_test.rb", "vk_api.gemspec"]
  s.homepage = "https://github.com/oruen/vk_api"
  s.require_paths = ["lib"]
  s.rubyforge_project = "vk_api"
  s.rubygems_version = "1.8.24"
  s.summary = "\u{413}\u{435}\u{43c} \u{434}\u{43b}\u{44f} \u{43e}\u{431}\u{449}\u{435}\u{43d}\u{438}\u{44f} \u{441} Open API \u{441}\u{430}\u{439}\u{442}\u{430} \u{412}\u{41a}\u{43e}\u{43d}\u{442}\u{430}\u{43a}\u{442}\u{435}"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end
