module PhantomPDF
  class Middleware
    REGEXP_PDF = /\.pdf\z/i

    def initialize(app, output=nil)
      @app = app
      @output = output
    end

    def call(env)
      @request = Rack::Request.new(env)

      return @app.call(env) unless request_pdf?

      status, headers, response = @app.call(env)
      return [status, headers, response] if status != 200 || headers['Content-Type'] != 'text/html'

      response_body = render_pdf(response.first)

      headers.merge!({
        'Content-Type' => 'application/pdf',
        'Content-Length' => response_body.size.to_s
      })

      [200, headers, [response_body]]
    end

  private
    def render_pdf(html)
      Generator.new(html, render_path).to_string
    end

    def render_path
      file_name = "#{Digest::MD5.hexdigest(@request.path)}.pdf"

      return Tempfile.new(file_name).path if @output.nil? || !File.directory?(@output) || !File.writable?(@output)

      "#{@output}/#{file_name}"
    end

    def request_pdf?
      return true if @request.path.match(Middleware::REGEXP_PDF)
      false
    end
  end
end
