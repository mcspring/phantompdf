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
        expect(Generator.new(resource).generate).to be_pdf_file
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
          expect(File.exist?(@destination)).to be false
          Generator.new(resource, @destination).generate
          expect(File.exist?(@destination)).to be true

          expect(@destination).to be_pdf_file
        end

        it "should raise PhantomPDF::DestinationTypeError when output is not a string" do
          expect{
            Generator.new(resource, Object.new)
          }.to raise_error(PhantomPDF::DestinationTypeError)
        end

        it "should raise PhantomPDF::DestinationPermitError when output is not writable" do
          allow(File).to receive(:writable?).with('/tmp').and_return(false)

          expect{
            Generator.new(resource, @destination)
          }.to raise_error(PhantomPDF::DestinationPermitError)
          expect(File).to have_received(:writable?)
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

          expect(Generator.new(resource, @destination, {:header => header}).generate).to be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(header)
        end

        it "should support images in custom header" do
          header = "1.8cm*PhantomPDF header!<img src=\"#{@custom_image}\" style=\"float:right;\"/>"

          expect(Generator.new(resource, @destination, {:header => header}).generate).to be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(@custom_image)
        end

        it "should support custom footer" do
          footer = 'Hello, PhantomPDF footer!'
          
          expect(Generator.new(resource, @destination, {:footer => footer}).generate).to be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(header)
        end

        it "should support images in custom footer" do
          footer = "1.8cm*PhantomPDF footer!<img src=\"#{@custom_image}\" style=\"float:right;\"/>"

          expect(Generator.new(resource, @destination, {:footer => footer}).generate).to be_pdf_file

          # we CANNOT reader the file as PDF
          # pdf_content = PDF::Reader.new(@destination).page(1).text
          # pdf_content.should include(@custom_image)
        end
      end
    end

    context "#generate!" do
      it "should raise PhantomPDF::RenderingError when failed to generate" do
        allow($?).to receive(:exitstatus).and_return(1)

        generator = Generator.new(resource)
        allow(generator).to receive(:run).and_return('rendering error')

        expect{
          generator.generate!
        }.to raise_error(PhantomPDF::RenderingError)
      end
    end

    context "#to_string" do
      it "should return string of PDF file" do
        expect(Generator.new(resource).to_string).to be_pdf_string
      end
    end
  end
end
