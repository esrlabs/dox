module Dim
  # This is how the interface is used by the Dim::Export:
  #
  # initialize()
  #
  # for every document:
  #   header()
  #   document()
  #   metadata()
  #   for every requirement in document:
  #     requirement()
  #   footer()
  #
  # if hasIndex:
  #   for every originator/category combination:
  #     index()
  class ExporterInterface
    attr_reader :hasIndex

    # Returns the extension (suffix) the exporter should use for the exported
    # files. By default this matches the EXPORTER type associated with the class.
    # Subclasses can override the method to change the default behaviour.
    # @return [String] The extension for the exported files.
    def self.file_extension
      EXPORTER.key(self)
    end

    def initialize(loader)
      @hasIndex = false
      @loader = loader
    end

    def header(f); end

    def document(f, name); end

    def metadata(f, metadata); end

    def requirement(f, r); end

    def footer(f); end

    def index(f, category, origin, modules); end
  end
end
