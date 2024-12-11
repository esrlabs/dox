# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/indent'
require 'active_support/core_ext/object/blank'
require 'erb'

require_relative 'exporterInterface'

module Dim
  # Exports the requirements to a raw RST format. It doesn't perform
  # transformations to the requirements' text and it doesn't use any custom RST
  # directives.
  # The output is fully compatible with any RST template provided that the text
  # in the requirements is also valid RST code.
  class RawRST < ExporterInterface
    EXPORTER['raw-rst'] = self

    # Path to the directory where the ERB templates are stored.
    TEMPLATE_DIRECTORY = Pathname.new(__dir__) / 'templates' / 'raw_rst'

    # Path to the ERB template used for the index.
    INDEX_TEMPLATE = TEMPLATE_DIRECTORY / 'index.rst.erb'

    # Path to the ERB template used for the document.
    DOCUMENT_TEMPLATE = TEMPLATE_DIRECTORY / 'document.rst.erb'

    # Path to the ERB template used for each requirement.
    REQUIREMENT_TEMPLATE = TEMPLATE_DIRECTORY / 'requirement.rst.erb'

    # @return [String] The extension that should be used for the files generated
    #   for this exporter.
    def self.file_extension
      'rst'
    end

    # @param [Dim::Loader] loader The loader used to load the requirements.
    def initialize(loader)
      super
      @hasIndex = true
    end

    # @param [StringIO] buffer The buffer the content should be written to.
    # @param [String] category The current category, for example: 'software',
    #   'architecture', etc.
    # @param [String] origin The origin of the requirements, for example
    #   'ACME Inc.'
    # @param [Array<String>] documents The name of the documents for the current
    #   category / origin pair.
    def index(buffer, category, origin, documents)
      buffer << ERB.new(INDEX_TEMPLATE.read, trim_mode: '<>').result_with_hash(
        category: category, origin: origin, documents: documents,
      )
    end

    # @param [StringIO] buffer The buffer the content should be written to.
    # @param [String] document The name of the document.
    def document(buffer, document)
      buffer << ERB.new(document_template_content).result_with_hash(
        document: document
      ) << "\n"
    end

    # @param [StringIO] buffer The buffer the content should be written to.
    # @param [Dim::Requirement] requirement The requirement to render.
    def requirement(buffer, requirement)
      buffer << ERB.new(requirement_template_content, trim_mode: '<>').result_with_hash(
        requirement: requirement, requirement_id: requirement.id,
        asil: requirement.asil == "not_set" ? nil : requirement.asil,
        text: requirement_text(requirement),
        downstream_references: reference_links(requirement.downstreamRefs),
        upstream_references: reference_links(requirement.upstreamRefs)
      ) << "\n"
    end

    private

    # @return [String] A fragment of ERB code. The content of the template used
    #   to render the document. Since the template is used repeatedly, it gets
    #   read once and memoized.
    def document_template_content
      @document_template_content ||= DOCUMENT_TEMPLATE.read
    end

    # @return [String] A fragment of ERB code. The content of the template used
    #   to render the requirements. Since the template is used repeatedly, it
    #   gets read once and memoized.
    def requirement_template_content
      @requirement_template_content ||= REQUIREMENT_TEMPLATE.read
    end

    # Extracts the text from the given requirement and returns a string with
    # it keeping the correct indentation from the second line onwards.
    # @param [Dim::Requirement] requirement The requirement whose text should be
    #   extracted
    # @return [String] A fragment of RST code with the text extracted from the
    #   given requirement.
    def requirement_text(requirement)
      buffer = StringIO.new
      text_lines = requirement.text.lines.map(&:chomp)
      buffer << text_lines.shift

      if text_lines.any?
        text_lines.each do |line|
          buffer << "\n#{line.indent(7)}"
        end

        buffer << "\n"
      end

      buffer.string
    end

    # @param [Array<String>] references The array of references to create links for.
    # @return [String] A fragment of RST code with links to the given references.
    #   Or the text "none" if +references+ is empty.
    def reference_links(references)
      return "none" unless references.any?

      references.map { |ref| ":ref:`dim-req-#{ref}`" }.join(', ')
    end
  end
end
