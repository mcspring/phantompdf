# -*- encoding: utf-8 -*-
phantompdf_lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(phantompdf_lib) unless $LOAD_PATH.include?(phantompdf_lib)

require 'phantompdf/version'

Gem::Specification.new do |spec|
  spec.name = 'phantompdf'
  spec.version = PhantomPDF::VERSION
  spec.authors = ['Spring MC']
  spec.email = %w(Heresy.Mc@gmail.com)
  spec.description = %q{Generate PDF from HTML using PhantomJS}
  spec.summary = %q{A PhantomJS based PDF generator}
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/mcspring/phantompdf'
  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)
  spec.add_runtime_dependency 'phantomjs'
  spec.add_runtime_dependency 'json'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pdf-reader'
  spec.add_development_dependency 'byebug'
end
