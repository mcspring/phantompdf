require 'uri'

module PhantomPDF
  class Source
    def initialize(src)
      @source = src

      raise SourceTypeError.new('Unsupported source type.') unless valid?
    end

    def url?
      !URI.parse(@source).scheme.nil?
    rescue
      false
    end

    def file?
      !url? && (@source.kind_of?(File) || File.exists?(@source))
    end

    def html?
      !(url? || file?)
    end

    def valid?
      url? || file? || html?
    end

    def to_s
      return @source if url? || html?

      @source.kind_of?(File) ? @source.path : @source
    end
  end
end
