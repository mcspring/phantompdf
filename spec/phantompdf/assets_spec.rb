require 'spec_helper'

module PhantomPDF
  describe Assets do
    context ".root" do
      it "should return vendor folder" do
        File.directory?(Assets.root).should be_true
      end
    end

    context ".javascripts" do
      it "should return rasterize.js abs path" do
        File.exist?(Assets.javascripts('rasterize')).should be_true
      end

      it "should return nil for un-existed file" do
        Assets.javascripts('un-exist-javascript').should be_nil
      end
    end
  end
end
