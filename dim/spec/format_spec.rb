require_relative 'framework/helper'

module Dim
  describe 'dim format' do
    def compareFormat(f)
      Test.main("format -i #{TEST_INPUT_DIR}/format/#{f} --output-format extra")
      expect($test_exception).to be nil
      formatted = File.read("#{TEST_INPUT_DIR}/format/#{f}.formatted").universal_newline
      expected  = File.read("#{TEST_INPUT_DIR}/format/#{f}.expected").universal_newline
      expect(formatted).to eq(expected)
    end

    context 'shall allow missing references while formatting regardless of output format' do
      it 'when output-format is check-only', doc_refs: %w[Dim_format_general] do
        Test.main("format -i #{TEST_INPUT_DIR}/missing_refs/test_module_1.dim --output-format check-only")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).not_to include('"test_id_3" refers to non-existing "non_exist"')
        expect(@test_stderr).to include('Error: The following files are not formatted correctly')
        expect(@test_stdout).not_to include("Using 'allow-missing' might influence metrics when some references are ignored!")
      end

      it 'when output-format is extra', doc_refs: %w[Dim_format_general] do
        Test.main("format -i #{TEST_INPUT_DIR}/missing_refs/test_module_1.dim --output-format extra")

        formatted = File.read("#{TEST_INPUT_DIR}/missing_refs/test_module_1.dim.formatted")
        expected = File.read("#{TEST_INPUT_DIR}/missing_refs/test_module_1.dim.expected")

        expect(formatted).to eq(expected)
      end
    end

    context 'shall support output-format' do
      it '"in-place" by default', doc_refs: %w[Dim_format_general Dim_format_inPlace Dim_loading_readGood] do
        path = "#{TEST_INPUT_DIR}/format/inplace"
        %w[first second].each { |f| FileUtils.cp_r("#{path}/#{f}.dim", "#{path}/#{f}.inplace.dim") }
        Test.main("format -i #{TEST_INPUT_DIR}/format/inplace/complete.conf")

        %w[first second].each do |f|
          formatted = File.read("#{path}/#{f}.inplace.dim").universal_newline
          expected = File.read("#{path}/#{f}.dim.expected").universal_newline
          expect(formatted).to eq(expected)
          FileUtils.rm_f("#{path}/#{f}.inplace.dim")
        end
      end

      it '"extra" files', doc_refs: ['Dim_format_extra'] do
        path = "#{TEST_INPUT_DIR}/format/inplace"
        %w[first second].each { |f| FileUtils.cp_r("#{path}/#{f}.dim", "#{path}/#{f}.inplace.dim") }
        Test.main("format -i #{TEST_INPUT_DIR}/format/inplace/complete_extra.conf --output-format extra")

        %w[first second].each do |f|
          formatted = File.read("#{path}/#{f}.dim.formatted").universal_newline
          expected = File.read("#{path}/#{f}.dim.expected").universal_newline
          expect(formatted).to eq(expected)
          FileUtils.rm_f("#{path}/#{f}.dim.formatted")
        end
      end

      it '"check-only", valid files shall not lead to an error', doc_refs: ['Dim_format_checkOnly'] do
        Test.main("format -i #{TEST_INPUT_DIR}/format/empty/none.dim --output-format check-only")
        expect(@test_stderr).not_to include('Error: The following files are not formatted correctly:')
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      it '"check-only", invalid files shall lead to an error and a meaningful error message shall be printed',
         doc_refs: ['Dim_format_checkOnly'] do
        Test.main("format -i #{TEST_INPUT_DIR}/format/collection/complete.conf --output-format check-only")
        expect(@test_stderr).to include('Error: The following files are not formatted correctly:')
        expect(@test_stderr).to include('text.dim')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'with invalid output-format' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_format_general'] do
        Test.main("format -i #{TEST_INPUT_DIR}/format/empty/none.dim --output-format wrong")
        expect(@test_stderr).to include('output-format must be in-place, extra or check-only')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'use case:' do
      it 'empty file', doc_refs: ['Dim_format_general'] do
        compareFormat('empty/none.dim')
      end

      it 'only module attribute', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/onlyModule.dim')
      end

      it 'only metadata metadata', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/metadataEmpty.dim')
        compareFormat('collection/metadataString.dim')
      end

      it 'only enclosed', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/enclosedArray.dim')
        compareFormat('collection/enclosedString.dim')
      end

      it 'one liners', doc_refs: ['Dim_format_form'] do
        compareFormat('collection/oneLiners.dim')
      end

      it 'single enums', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/type.dim')
        compareFormat('collection/status.dim')
        compareFormat('collection/review_status.dim')
        compareFormat('collection/asil.dim')
        compareFormat('collection/cal.dim')
      end

      it 'multi enums', doc_refs: %w[Dim_format_whitespaces Dim_format_default Dim_format_duplicated] do
        compareFormat('collection/tags.dim')
        compareFormat('collection/test_setups.dim')
        compareFormat('collection/verification_methods.dim')
      end

      it 'lists', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/developer.dim')
        compareFormat('collection/tester.dim')
      end

      it 'refs', doc_refs: %w[Dim_format_whitespaces Dim_format_default Dim_format_duplicated] do
        compareFormat('collection/refs.dim')
      end

      it 'sources', doc_refs: %w[Dim_format_whitespaces Dim_format_default Dim_format_duplicated] do
        compareFormat('collection/sources.dim')
      end

      it 'textual fields', doc_refs: %w[Dim_format_whitespaces Dim_format_default] do
        compareFormat('collection/text.dim')
        compareFormat('collection/verification_criteria.dim')
        compareFormat('collection/comment.dim')
        compareFormat('collection/miscellaneous.dim')
        compareFormat('collection/feature.dim')
        compareFormat('collection/change_request.dim')
      end

      it 'properties file shall have no influence', doc_refs: ['Dim_format_general'] do
        Test.main("format -i #{TEST_INPUT_DIR}/format/collection/asil.conf --output-format extra")
        formatted = File.read("#{TEST_INPUT_DIR}/format/collection/asil.dim.formatted").universal_newline
        expected  = File.read("#{TEST_INPUT_DIR}/format/collection/asil.dim.expected").universal_newline
        expect(formatted).to eq(expected)
      end

      it 'order', doc_refs: ['Dim_format_order'] do
        compareFormat('collection/order.dim')
      end
    end

    context 'shall not include test_setups' do
      it 'shall format the document with verification_methods and not test_setups',
         doc_refs: %w[Dim_format_verificationMethods] do
        Test.main("format -i #{TEST_INPUT_DIR}/verification_methods/verification_methods.dim --output-format extra")
        expected = File.read("#{TEST_INPUT_DIR}/verification_methods/verification_methods.dim.expected")
        actual = File.read("#{TEST_INPUT_DIR}/verification_methods/verification_methods.dim.formatted")
        expect(actual).to eq expected

        Test.main("format -i #{TEST_INPUT_DIR}/verification_methods/single_none.dim --output-format extra")
        expected = File.read("#{TEST_INPUT_DIR}/verification_methods/single_none.dim.expected")
        actual = File.read("#{TEST_INPUT_DIR}/verification_methods/single_none.dim.formatted")
        expect(actual).to eq expected

        Test.main("format -i #{TEST_INPUT_DIR}/verification_methods/all_none.dim --output-format extra")
        expected = File.read("#{TEST_INPUT_DIR}/verification_methods/all_none.dim.expected")
        actual = File.read("#{TEST_INPUT_DIR}/verification_methods/all_none.dim.formatted")
        expect(actual).to eq expected

        Test.main("format -i #{TEST_INPUT_DIR}/verification_methods/single_none.dim --output-format extra")
        expected = File.read("#{TEST_INPUT_DIR}/verification_methods/single_none.dim.expected")
        actual = File.read("#{TEST_INPUT_DIR}/verification_methods/single_none.dim.formatted")
        expect(actual).to eq expected
      end
    end

    context 'shall ignore different line-endings:' do
      it 'LF compared to OS default', doc_refs: ['Dim_format_checkOnly'] do
        content = File.read("#{TEST_INPUT_DIR}/format_lineendings/lf.dim", mode: 'rb')
        expect(content).not_to include("\r\n")
        Test.main("format -i #{TEST_INPUT_DIR}/format_lineendings/lf.dim --output-format check-only")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
      it 'CRLF compared to OS default', doc_refs: ['Dim_format_checkOnly'] do
        content = File.read("#{TEST_INPUT_DIR}/format_lineendings/crlf.dim", mode: 'rb')
        expect(content).to include("\r\n")
        Test.main("format -i #{TEST_INPUT_DIR}/format_lineendings/crlf.dim --output-format check-only")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
      it 'Mixed compared to OS default', doc_refs: ['Dim_format_checkOnly'] do
        content = File.read("#{TEST_INPUT_DIR}/format_lineendings/mixed.dim", mode: 'rb')
        expect(content).to include("\r\nSRS_A_B:\n ")
        Test.main("format -i #{TEST_INPUT_DIR}/format_lineendings/mixed.dim --output-format check-only")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
    end

    context 'when output format is stdout' do
      before { allow($stdin).to receive(:read).and_return(content) }

      let(:content) { File.read("#{TEST_INPUT_DIR}/format/collection/order.dim") }
      let(:formatted_content) { File.read("#{TEST_INPUT_DIR}/format/collection/order.dim.expected") }

      it 'reads the content from STDIN and prints out content in STDOUT', doc_refs: ['Dim_format_vim'] do
        Test.main('format --output-format stdout')
        expect(@test_stdout).to include(formatted_content)
      end
    end

    context 'when custom attributes are given' do
      it 'loads the custom attributes and format the requirements',
         doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_format_customAttributes] do
        Test.main(
          "format -i #{TEST_INPUT_DIR}/format/with_custom_attributes/Config.dim --output-format extra"
        )

        expected = File.read("#{TEST_INPUT_DIR}/format/with_custom_attributes/test_module.dim.expected").universal_newline
        actual = File.read("#{TEST_INPUT_DIR}/format/with_custom_attributes/test_module.dim.formatted").universal_newline

        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(actual).to eq(expected)
      end
    end

    context 'document' do
      context 'when present' do
        it 'shall format the document', doc_refs: %w[Dim_loading_document Dim_format_general] do
          Test.main("format -i #{TEST_INPUT_DIR}/document/document.dim --output-format extra")

          expected = File.read("#{TEST_INPUT_DIR}/document/document.dim.expected")
          actual = File.read("#{TEST_INPUT_DIR}/document/document.dim.formatted")

          expect(actual).to eq(expected)
        end
      end

      context 'when module is given' do
        it 'shall replace the module with document', doc_refs: %w[Dim_loading_document Dim_format_general] do
          Test.main("format -i #{TEST_INPUT_DIR}/document/modulename.dim --output-format extra")

          expected = File.read("#{TEST_INPUT_DIR}/document/modulename.dim.expected")
          actual = File.read("#{TEST_INPUT_DIR}/document/modulename.dim.formatted")

          expect(actual).to eq(expected)
        end
      end
    end

    context 'when invalid format style is present' do
      before do
        Dim::Requirement::SYNTAX['dummy'] =
          { check: nil, format_style: :dummy, format_shift: 0, default: '', allowed: nil }
      end

      it 'shall throw a meaningful error and exit', doc_refs: ['Dim_format_general'] do
        Test.main("format -i #{TEST_INPUT_DIR}/invalid_format_style/module.dim --output-format extra")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'Error: Invalid format style'
      end
    end
  end
end
