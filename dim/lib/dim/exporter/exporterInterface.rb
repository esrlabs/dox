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
