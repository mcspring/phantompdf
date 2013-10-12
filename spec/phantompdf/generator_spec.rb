require 'spec_helper'

module PhantomPDF
  fixtures_root = File.expand_path('../../fixtures', __FILE__)

  resource = {
    url: 'http://www.google.com',
    file: "#{fixtures_root}/phantompdf.html",
    html: File.read("#{fixtures_root}/phantompdf.html")
  }.values.sample

  describe Generator do
    subject { Generator.new(resource) }

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
      it "should works" do
        Generator.new(resource).generate.should be_pdf_file
      end

      context "with output" do
        before :each do
          @destination = '/tmp/google.pdf'

          File.unlink(@destination) if File.exist?(@destination)
        end

        after :each do
          File.unlink(@destination) if File.exist?(@destination)
        end

        it "should generate pdf file following output" do
          File.exist?(@destination).should be_false
          Generator.new(resource, @destination).generate
          File.exist?(@destination).should be_true

          @destination.should be_pdf_file
        end

        it "should raise PhantomPDF::DestinationTypeError when output is not a string" do
          expect{
            Generator.new(resource, Object.new)
          }.to raise_error(PhantomPDF::DestinationTypeError)
        end

        pending "should raise PhantomPDF::DestinationPermitError when output is not writable" do
          File.stub(:writable?, '/tmp') { false }

          expect{
            Generator.new(resource, @destination)
          }.to raise_error(PhantomPDF::DestinationPermitError)
        end
      end

      context "with options" do
        before :each do
          @destination = '/tmp/google.pdf'
          @custom_image = 'http://www.google.com/images/srpr/logo4w.png'

          File.unlink(@destination) if File.exist?(@destination)
        end

        after :each do
          File.unlink(@destination) if File.exist?(@destination)
        end

        it "should support custom header" do
          header = 'Hello, PhantomPDF header!'

          Generator.new(resource, @destination, {:header => header}).generate.should be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(header)
        end

        it "should support images in custom header" do
          header = "1.8cm*PhantomPDF header!<img src=\"#{@custom_image}\" style=\"float:right;\"/>"

          Generator.new(resource, @destination, {:header => header}).generate.should be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(@custom_image)
        end

        it "should support custom footer" do
          footer = 'Hello, PhantomPDF footer!'

          Generator.new(resource, @destination, {:footer => footer}).generate.should be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(header)
        end

        it "should support images in custom footer" do
          footer = "1.8cm*PhantomPDF footer!<img src=\"#{@custom_image}\" style=\"float:right;\"/>"

          Generator.new(resource, @destination, {:footer => footer}).generate.should be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(@custom_image)
        end
      end
    end

    context "#generate!" do
      it "should raise PhantomPDF::RenderingError when failed to generate" do
        $?.stub(:exitstatus) { 1 }

        generator = Generator.new(resource)
        generator.stub(:run) { 'rendering error' }

        expect{
          generator.generate!
        }.to raise_error(PhantomPDF::RenderingError)
      end
    end

    context "#to_string" do
      it "should return string of PDF file" do
        Generator.new(resource).to_string.should be_pdf_string
      end
    end
  end
end
