require 'spec_helper'

module PhantomPDF
  describe Config do
    before do
      @config = Config.new
    end

    context "#phantomjs" do
      it "should respond to :phantomjs" do
        expect(@config).to respond_to(:phantomjs)
      end

      it "should return phantomjs bin path" do
        expect(@config.phantomjs).to eq Phantomjs.path
      end
    end

    [:format, :header, :footer, :margin, :zoom, :orientation, :cookies, :timeout, :rendering_timeout].each do |method|
      method = :"#{method}="

      it "should respond to #{method}" do
        expect(@config).to respond_to(method)
      end
    end
  end
end
