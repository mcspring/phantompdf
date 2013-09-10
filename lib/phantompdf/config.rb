module PhantomPDF
  class Config
    attr_accessor :default_options
    attr_reader :phantomjs

    def initialize(options={})
      @default_options = {
        :format            => 'A4',
        :header            => nil,
        :footer            => nil,
        :margin            => '1cm',
        :orientation       => 'portrait',
        :zoom              => 1,
        :cookies           => {},
        :timeout           => 90000,
        :rendering_timeout => 1000
      }

      @default_options.merge! options || {}
    end

    def phantomjs
      @phantomjs ||= ::Phantomjs.path
    end

    [:format, :header, :footer, :margin, :orientation, :zoom, :cookies, :timeout, :rendering_timeout].each do |key|
      define_method("#{key}=") do |val|
        @default_options[key] = val
      end
    end
  end

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
