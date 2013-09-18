require 'phantomjs'
require 'phantompdf/version'
require 'phantompdf/error'
require 'phantompdf/assets'
require 'phantompdf/source'
require 'phantompdf/config'
require 'phantompdf/generator'
require 'phantompdf/middleware'

module PhantomPDF
  # Configure PhantomPDF someplace sensible,
  # like config/initializers/phantompdf.rb
  #
  # @example
  #   PhantomPDF.configure do |config|
  #     config.format            = 'A4',
  #     config.header            = nil,
  #     config.footer            = nil,
  #     config.margin            = '1cm',
  #     config.orientation       = 'portrait',
  #     config.zoom              = 1,
  #     config.cookies           = {},
  #     config.timeout           = 90000,
  #     config.rendering_timeout = 1000
  #   end
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Config.new
  end

  def self.configure
    yield(configuration)
  end
end
