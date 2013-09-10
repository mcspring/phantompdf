require 'phantomjs'
require 'phantompdf'
require 'pdf-reader'
require 'byebug'

require 'rack/test'

RSpec.configure do |config|
  # some staff goes here
end

RSpec::Matchers.define :be_pdf_file do
  match do |actual|
    case actual
    when File
      actual.read[0...4] == '%PDF'
    when String
      File.exist?(actual) && File.open(actual).read[0...4] == '%PDF'
    end
  end
end

RSpec::Matchers.define :be_pdf_string do
  match do |actual|
    actual[0...4] == '%PDF'
  end
end
