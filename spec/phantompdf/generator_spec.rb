require 'spec_helper'

module PhantomPDF
  describe Generator do
    let(:fixtures_root) {
      File.expand_path('../../fixtures', __FILE__)
    }

    subject { Generator.new("#{fixtures_root}/phantompdf.html") }

    context "attributes" do
      [:input, :output, :config].each do |rwattr|
        it { should respond_to(rwattr) }
        it { should respond_to("#{rwattr}=".to_sym) }
      end

      [:options, :cookies, :exception].each do |rattr|
        it { should respond_to(rattr) }
        it { should_not respond_to("#{rattr}=") }
      end
    end

    context "#generate" do
      fixtures_root = File.expand_path('../../fixtures', __FILE__)

      {
        url: 'http://www.google.com',
        file: "#{fixtures_root}/phantompdf.html",
        html: File.read("#{fixtures_root}/phantompdf.html")
      }.each do |key, value|
        context "with #{key}" do
          it "should works" do
            Generator.new(value).generate.should be_pdf_file
          end
        end
      end

      context "with output" do
        before :all do
          @url = 'http://www.google.com'
          @file = '/tmp/google.pdf'
        end

        after :each do
          File.exist?(@file) && File.unlink(@file)
        end

        it "should generate pdf file following :output" do
          File.exist?(@file).should be_false
          Generator.new(@url, @file).generate
          File.exist?(@file).should be_true

          @file.should be_pdf_file
        end

        it "should raise PhantomPDF::DestinationTypeError when :output is not a string" do
          expect{
            Generator.new(@url, Object.new)
          }.to raise_error(PhantomPDF::DestinationTypeError)
        end

        it "should raise PhantomPDF::DestinationPermitError when :output is not writable" do
          File.stub(:writable?, '/tmp') { false }

          expect{
            Generator.new(@url, @file)
          }.to raise_error(PhantomPDF::DestinationPermitError)
        end
      end

      context "with options for pdf format" do
        before :all do
          @url = 'http://www.google.com'
          @file = '/tmp/google.pdf'
          @image = 'http://www.google.com/images/srpr/logo4w.png'
        end

        after :each do
          File.exist?(@file) && File.unlink(@file)
        end

        pending "should support custom :header" do
          header = 'Hello, PhantomPDF header!'

          Generator.new(@url, @file, {:header => header}).generate

          pdf_content = PDF::Reader.new(@file).page(1).text
          pdf_content.should include(header)
        end

        it "should support images in custom header" do
          header = "1.8cm*PhantomPDF header!<img src=\"#{@image}\" style=\"float:right;\"/>"

          Generator.new(@url, @file, {header: header}).generate.should be_pdf_file
        end

        pending "should support custom :footer" do
          header = 'Hello, PhantomPDF footer!'

          Generator.new(@url, @file, {:footer => header}).generate

          pdf_content = PDF::Reader.new(@file).page(1).text
          pdf_content.should include(header)
        end

        it "should support images in custom header or footer" do
          footer = "1.8cm*PhantomPDF footer!<img src=\"#{@image}\" style=\"float:right;\"/>"

          Generator.new(@url, @file, {footer: footer}).generate.should be_pdf_file
        end
      end
    end

    context "#generate!" do
      before :all do
        @url = 'http://www.google.com'
      end

      it "should raise PhantomPDF::RenderingError when failed to generate" do
        $?.stub(:exitstatus) { 1 }

        generator = Generator.new(@url)
        generator.stub(:run) { 'rendering error' }

        expect{
          generator.generate!
        }.to raise_error(PhantomPDF::RenderingError)
      end
    end

    context "#to_string" do
      before :all do
        @url = 'http://www.google.com'
      end

      it "should return string" do
        Generator.new(@url).to_string.should be_pdf_string
      end
    end
  end
end
