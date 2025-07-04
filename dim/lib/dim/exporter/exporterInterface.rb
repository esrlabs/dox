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
    attr_reader :has_index

    def initialize(loader)
      @has_index = false
      @loader = loader
    end

    def header(file_io); end

    def document(file_io, name); end

    def metadata(file_io, metadata); end

    def requirement(file_io, req); end

    def footer(file_io); end

    def index(file_io, category, origin, modules); end
  end
end
