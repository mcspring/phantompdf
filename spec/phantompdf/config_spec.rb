require 'spec_helper'

module PhantomPDF
  describe Config do
    before do
      @config = Config.new
    end

    context "#phantomjs" do
      it "should respond to :phantomjs" do
        @config.should respond_to(:phantomjs)
      end

      it "should return phantomjs bin path" do
        @config.phantomjs.should == Phantomjs.path
      end
    end

    [:format, :header, :footer, :margin, :zoom, :orientation, :cookies, :timeout, :rendering_timeout].each do |method|
      method = :"#{method}="

      it "should respond to #{method}" do
        @config.should respond_to(method)
      end
    end
  end
end
