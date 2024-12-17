# frozen_string_literal: true

require 'dim/globals'
require 'dim/loader'
require 'dim/exporter/raw_rst'

RSpec.describe Dim::RawRST do
  subject(:raw_rst) { described_class.new(loader) }

  let(:loader) do
    instance_double(Dim::Loader)
  end

  describe '.file_extension' do
    subject(:method_call) { described_class.file_extension }

    it 'returns "rst"' do
      expect(method_call).to eq('rst')
    end
  end

  describe '#initialize' do
    subject(:method_call) { raw_rst }

    it 'sets hasIndex to true' do
      expect(raw_rst.hasIndex).to be(true)
    end
  end

  describe '#index' do
    subject(:method_call) { raw_rst.index(buffer, category, origin, modules) }

    let(:buffer) { StringIO.new }
    let(:origin) { 'ACME Inc.' }

    context 'when the category is "software"' do
      let(:category) { 'software' }
      let(:modules) { %w[SRS_Safety SRS_RealTime SRS_Basics] }

      let(:expected_text) do
        <<~RST
          Software
          ========

          .. toctree::
             :maxdepth: 1

             SRS_Safety/Requirements
             SRS_RealTime/Requirements
             SRS_Basics/Requirements
        RST
      end

      it 'generates the expected text, with the expected TOC entries',
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstIndex] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the category is "module"' do
      let(:category) { 'module' }
      let(:modules) { %w[SMD_SafeMCU SMD_ConsoleAdapter SMD_CANDriver] }

      let(:expected_text) do
        <<~RST
          Module
          ======

          .. toctree::
             :maxdepth: 1

             SMD_SafeMCU/Requirements
             SMD_ConsoleAdapter/Requirements
             SMD_CANDriver/Requirements
        RST
      end

      it 'generates the expected text, with the expected TOC entries',
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstIndex] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end
  end

  describe '#document' do
    subject(:method_call) { raw_rst.document(buffer, module_name) }

    let(:buffer) { StringIO.new }

    context 'when the module name is "SRS_CommandLine"' do
      let(:module_name) { 'SRS_CommandLine' }

      let(:expected_text) do
        <<~RST
          SRS_CommandLine
          ===============

        RST
      end

      it 'generates the expected text, with the expected title', doc_refs: %w[Dim_export_raw_rst] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the module name is "SWA_CommandParser"' do
      let(:module_name) { 'SWA_CommandParser' }

      let(:expected_text) do
        <<~RST
          SWA_CommandParser
          =================

        RST
      end

      it 'generates the expected text, with the expected title', doc_refs: %w[Dim_export_raw_rst] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end
  end

  describe '#requirement' do
    subject(:method_call) { raw_rst.requirement(buffer, requirement) }

    let(:buffer) { StringIO.new }

    let(:id) { 'ACME_REQ_6078' }
    let(:asil) { 'not_set' }

    let(:text) do
      <<~RST
        The Command Line's Command Parser shall be able to parse the program'
        command line arguments and:

        * Print an error when an unrecognized command is given.
        * Instantiate the correct command executor and give it the correct
          arguments.
      RST
    end

    let(:downstream_refs) { [] }
    let(:upstream_refs) { [] }
    let(:review_status) { "accepted" }
    let(:tags) { [] }
    let(:verification_methods) { [] }

    let(:requirement) do
      instance_double(
        Dim::Requirement,
        id: id,
        asil: asil,
        text: text,
        downstreamRefs: downstream_refs,
        upstreamRefs: upstream_refs,
        review_status: review_status,
        origin: 'ACME Inc.',
        tags: tags,
        verification_methods: verification_methods
      )
    end

    context "when the requirement's ASIL is not set" do
      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** 
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** none
             * - **Upstream References:** none

        RST
      end

      it 'generates the expected text, without the ASIL', doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context "when the requirement's ASIL is set" do
      let(:id) { 'ACME_SAFE_REQ_3782' }
      let(:asil) { 'ASIL_B' }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_SAFE_REQ_3782`:

          ACME_SAFE_REQ_3782
          ------------------

          .. list-table::

             * - **ACME_SAFE_REQ_3782** | accepted | ASIL_B | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** 
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** none
             * - **Upstream References:** none

        RST
      end

      it 'generates the expected text, with the expected ASIL',
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the requirement has downstream references' do
      let(:downstream_refs) { %w[ACME_REQ_3786 ACME_REQ_2244 ACME_REQ_7242] }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** 
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** :ref:`dim-req-ACME_REQ_3786`, :ref:`dim-req-ACME_REQ_2244`, :ref:`dim-req-ACME_REQ_7242`
             * - **Upstream References:** none

        RST
      end

      it 'generates the expected text, with the expected links',
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the requirement has upstream references' do
      let(:upstream_refs) { %w[ACME_REQ_9325 ACME_REQ_6563] }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** 
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** none
             * - **Upstream References:** :ref:`dim-req-ACME_REQ_9325`, :ref:`dim-req-ACME_REQ_6563`

        RST
      end

      it 'generates the expected text, with the expected links',
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the requirement has tags' do
      let(:tags) { %w[covered tested] }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** covered, tested
             * - **Verification Methods:** 
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** none
             * - **Upstream References:** none

        RST
      end

      it "generates the expected text, with the requirement's tags",
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the requirement has validation methods' do
      let(:verification_methods) { %w[on_target manual] }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** on_target, manual
             * - The Command Line's Command Parser shall be able to parse the program'
                 command line arguments and:

                 * Print an error when an unrecognized command is given.
                 * Instantiate the correct command executor and give it the correct
                   arguments.
             * - **Downstream References:** none
             * - **Upstream References:** none

        RST
      end

      it "generates the expected text, with the requirement's validation methods",
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end

    context 'when the requirement has no text' do
      let(:text) { '' }

      let(:expected_text) do
        <<~RST
          .. _`dim-req-ACME_REQ_6078`:

          ACME_REQ_6078
          -------------

          .. list-table::

             * - **ACME_REQ_6078** | accepted | ACME Inc.
             * - **Tags:** 
             * - **Verification Methods:** 
             * - **Downstream References:** none
             * - **Upstream References:** none

        RST
      end

      it "generates the expected text, does not add an empty row in the middle",
         doc_refs: %w[Dim_export_raw_rst Dim_export_raw_rstText] do
        method_call
        expect(buffer.string).to eq(expected_text)
      end
    end
  end
end
