require 'uri'
require 'json'
require 'tempfile'

module PhantomPDF
  class Generator
    attr_accessor :input, :output, :config
    attr_reader :options, :cookies, :exception

    def initialize(input, output=nil, options={})
      @input = Source.new(input)
      @output = dump_output(output, !output.nil?)
      @options = Config.new(options).default_options
      @exception = nil
    end

    def generate(path=nil)
      @output = dump_output(path, true) unless path.nil?

      result = run
      unless $?.exitstatus == 0
        @exception = result.split(/\n/)

        return nil
      end

      result.strip
    end

    def generate!(path=nil)
      result = generate(path)
      raise RenderingError.new(@exception.join("\n")) if result.nil?

      result
    end

    def to_string
      result = generate(nil)
      return '' if result.nil?

      File.open(result, 'rb').read
    end

  protected
    def run
      ::Phantomjs.run(*dump_args)
    end

    def dump_output(path, strict)
      if strict
        raise DestinationTypeError.new('Destination must be a valid file path!') unless path.is_a?(String)
        path = File.expand_path(path)
        raise DestinationPermitError.new('Destination does not writable!') unless File.writable?(File.dirname(path))
      else
        path = path.is_a?(String) ? File.expand_path(path) : nil
        path = Tempfile.new('temp_pdf_file').path if path.nil? || !File.writable?(File.dirname(path))
      end

      path
    end

    def dump_args
      format, header, footer = options[:format], options[:header], options[:footer]
      zoom, margin, orientation = options[:zoom], options[:margin], options[:orientation]
      rendering_timeout, timeout = options[:rendering_timeout], options[:timeout]
      cookie_file = dump_cookies(options[:cookies])

      [Assets.javascripts('rasterize'),
       @input.to_s,
       @output,
       format, (header.nil? || header.empty? ? nil : "1.2cm*#{header}"), (footer.nil? || footer.empty? ? nil : "0.7cm*#{footer}"),
       margin, orientation, zoom,
       cookie_file,
       rendering_timeout, timeout].map(&:to_s)
    end

    def dump_cookies(cookies)
      cookie_host = @input.url? ? URI::parse(@input.to_s).host : '/'

      cookie_json = cookies.inject([]) {|ck, (k, v)| ck.push({:name => k, :value => v, :domain => cookie_host}); ck}.to_json
      return nil if cookie_json.empty?

      cookie_file = Tempfile.new('temp_cookie_file')
      cookie_file.write(cookie_json)
      cookie_file.path
    end
  end
end
