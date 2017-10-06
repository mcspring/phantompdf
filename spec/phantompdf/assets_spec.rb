require 'spec_helper'

module PhantomPDF
  describe Assets do
    context ".root" do
      it "should return vendor folder" do
        expect(File.directory?(Assets.root)).to be true
      end
    end

    context ".javascripts" do
      it "should return rasterize.js abs path" do
        expect(File.exist?(Assets.javascripts('rasterize'))).to be true
      end

      it "should return nil for un-existed file" do
        expect(Assets.javascripts('un-exist-javascript')).to be nil
      end
    end
  end
end
