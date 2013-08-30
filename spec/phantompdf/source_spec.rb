require 'spec_helper'

module PhantomPDF
  describe Source do
    before do
      @url = 'http://www.test.com'
      @file = File.expand_path('../../fixtures/file.html', __FILE__)
      @html = File.read(@file)

      @url_source = Source.new(@url)
      @file_source = Source.new(@file)
      @html_source = Source.new(@html)
    end

    context "#url?" do
      it "should return true for url" do
        @url_source.url?.should be_true
      end

      it "should return false for file" do
        @file_source.url?.should be_false
      end

      it "should return false for html" do
        @html_source.url?.should be_false
      end
    end

    context "#file?" do
      it "should return false for url" do
        @url_source.file?.should be_false
      end

      it "should return true for file" do
        @file_source.file?.should be_true
      end

      it "should return false for html" do
        @html_source.file?.should be_false
      end

      it "should return false if file does not exist" do
        Source.new('path/to/unexisted/file').file?.should be_false
      end
    end

    context "#html?" do
      it "should return false for url" do
        @url_source.html?.should be_false
      end

      it "should return false for file" do
        @file_source.html?.should be_false
      end

      it "should return true for html" do
        @html_source.html?.should be_true
      end
    end

    context "#valid?" do
      it "should return true for url" do
        @url_source.valid?.should be_true
      end

      it "should return true for file" do
        @file_source.valid?.should be_true
      end

      it "should return true for html" do
        @html_source.valid?.should be_true
      end
    end

    context "#to_s" do
      it "should return url for url source" do
        @url_source.to_s.should == @url
      end

      it "should return file path for file source" do
        @file_source.to_s.should == @file
      end

      it "should return html string for html source" do
        @html_source.to_s.should == @html
      end
    end
  end
end
