require 'spec_helper'

module PhantomPDF
  describe Middleware do
    include Rack::Test::Methods

    let(:page) { File.read File.expand_path('../../fixtures/phantompdf.html', __FILE__) }
    let(:phantompdf) do
      lambda {|env| [200, {'Content-Type' => 'text/html', 'Content-Length' => page.size.to_s}, [page]]}
    end
    let(:app) { Middleware.new(phantompdf, '/tmp') }

    it "should works" do
      get '/index.pdf'

      last_response.status.should == 200
      last_response.body.should be_pdf_string
    end

    it "should respond with original data without PDF request" do
      get '/'

      last_response.status.should == 200
      last_response.body.should_not be_pdf_string
    end
  end
end
