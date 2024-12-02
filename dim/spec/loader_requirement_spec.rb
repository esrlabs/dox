require_relative 'framework/helper'

module Dim
  describe 'Loading a requirements file' do
    context 'with invalid YAML character' do
      loader = Dim::Loader.new
      loader.load(file: "#{TEST_INPUT_DIR}/invalid_input/modules/yaml_syntax_invalid_char.dim")
      it 'shall exchange the character with valid replacement', doc_refs: ['Dim_Syntax_InvalidChars'] do
        req = loader.requirements['ESR-0010-4139']
        expect(req.data['text']).to match 'req[SOH]1'
      end
    end

    context 'with non-breaking spaces' do
      loader = Dim::Loader.new
      loader.load(file: "#{TEST_INPUT_DIR}/nb_space/module.dim")
      it 'shall replace them with regular spaces', doc_refs: ['Dim_Syntax_InvalidChars'] do
        expect(Dim::ExitHelper.exit_code).to be 0
        nbsreq = loader.requirements['Has_Non_Breaking_Space']
        expect(nbsreq.text).to eq 'ABC    ABC'
        expect(nbsreq.miscellaneous).to eq 'ABC    ABC'
      end
    end

    context 'with utf-8 encoding' do
      loader = Dim::Loader.new
      loader.load(file: "#{TEST_INPUT_DIR}/different_encodings/utf-8_input.dim")
      it 'shall not lead to an error', doc_refs: ['Dim_Syntax_utf8'] do
        req = loader.requirements['test_id_1']
        expect(req.data['text']).to match 'µC shall trigger ä if µP reaches temperature x°.'
      end
    end

    context 'with windows1250 encoding' do
      loader = Dim::Loader.new
      loader.load(file: "#{TEST_INPUT_DIR}/different_encodings/Windows1250_input.dim")
      it 'shall convert the data to UTF-8 and not lead to an error', doc_refs: ['Dim_Syntax_utf8'] do
        req = loader.requirements['test_id_1']
        expect(req.data['text']).to match '?C shall trigger ? if ?P reaches temperature x?.'
      end
    end

    context 'with ISO8859-1 encoding' do
      loader = Dim::Loader.new
      loader.load(file: "#{TEST_INPUT_DIR}/different_encodings/ISO8859-1_input.dim")
      it 'shall convert the data to UTF-8 and not lead to an error', doc_refs: ['Dim_Syntax_utf8'] do
        req = loader.requirements['test_id_1']
        expect(req.data['text']).to match '?C shall trigger ? if ?P reaches temperature x?.'
      end
    end

    context 'with ISO8859-1 encoding but invalid syntax' do
      let(:filename) { "#{TEST_INPUT_DIR}/different_encodings/ISO8859-1_input_invalid.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_Syntax_YAML'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'Error:'
        expect(@test_stderr).to include filename
      end
    end

    context 'with invalid top level attribute' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/modules/toplevel_invalid.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'top level must be a hash with keys "document", "enclosed", "metadata" and/or unique ids'
        expect(@test_stderr).to include filename
      end
    end

    context 'with invalid attribute name' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/modules/unallowed_attribute.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include 'attribute test not allowed'
        expect(@test_stderr).to include filename
      end
    end

    context 'with attribute name used twice for a requirement' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/modules/duplicate_keys.dim")
        expect(Dim::ExitHelper.exit_code).to be > 0
        # NOTE: line is optional, depends on the underlying psych version
        expect(@test_stderr).to match(/Error: (|line 6: )found "text" twice which must be unique\./)
      end
    end
  end
end
