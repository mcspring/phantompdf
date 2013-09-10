module PhantomPDF
  class Error < StandardError; end
  class SourceTypeError < Error; end
  class DestinationTypeError < Error; end
  class DestinationPermitError < Error; end
  class RenderingError < Error; end
end
