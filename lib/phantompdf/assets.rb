module PhantomPDF
  class Assets
    attr_accessor :root, :javascripts

    class << self
      def root
        @root ||= File.expand_path('../../../', __FILE__)
      end

      def javascripts(name)
        @javascripts ||= {}

        @javascripts[name] ||= "#{root}/vendor/assets/javascripts/#{name}.js"
        @javascripts[name] = nil unless File.exist?(@javascripts[name])

        @javascripts[name]
      end
    end
  end
end
