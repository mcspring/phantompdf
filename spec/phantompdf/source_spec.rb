require 'spec_helper'

module PhantomPDF
  describe Source do
    before do
      @url = ['http://www.test.com', 'file://tmp/phantompdf.html', 'ftp://phantompdf:passwd@test.com/phantompdf.html'].sample
      @file = File.expand_path('../../fixtures/phantompdf.html', __FILE__)
      @html = File.read(@file)

      @url_source = Source.new(@url)
      @file_source = Source.new(@file)
      @html_source = Source.new(@html)
    end

    context "#url?" do
      it "should return true for url" do
        expect(@url_source).to be_url
      end

      it "should return false for file" do
        expect(@file_source).not_to be_url
      end

      it "should return false for html" do
        expect(@html_source).not_to be_url
      end
    end

    context "#file?" do
      it "should return false for url" do
        expect(@url_source).not_to be_file
      end

      it "should return true for file" do
        expect(@file_source).to be_file
      end

      it "should return false for html" do
        expect(@html_source).not_to be_file
      end

      context 'when the file does not exist' do
        subject { Source.new('path/to/unexisted/file') }
        
        it { is_expected.not_to be_file }
      end
    end

    context "#html?" do
      it "should return false for url" do
        expect(@url_source).not_to be_html
      end

      it "should return false for file" do
        expect(@file_source).not_to be_html
      end

      it "should return true for html" do
        expect(@html_source).to be_html
      end
    end

    context "#valid?" do
      it "should return true for url" do
        expect(@url_source).to be_valid
      end

      it "should return true for file" do
        expect(@file_source).to be_valid
      end

      it "should return true for html" do
        expect(@html_source).to be_valid
      end
    end

    context "#to_s" do
      it "should return url for url source" do
        expect(@url_source.to_s).to eq @url
      end

      it "should return file path for file source" do
        expect(@file_source.to_s).to eq @file
      end

      it "should return html string for html source" do
        expect(@html_source.to_s).to eq @html
      end
    end
  end
end
