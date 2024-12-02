require_relative 'framework/helper'

module Dim
  describe 'Loading a file' do
    context 'which does not exist' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/non_exist.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'does not exist'
      end
    end

    context 'which is empty and therefore invalid YAML' do
      let(:filepath) { "#{TEST_INPUT_DIR}/invalid_input/no_yaml.dim" }

      it 'shall print warning message and skip loading of file', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{filepath}")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).to include("Warning: empty file detected; skipped loading of #{filepath}")
      end
    end

    context 'which has invalid yaml syntax' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/modules/yaml_syntax_invalid.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'mapping values are not allowed in this context at line 4 column 18'
        expect(@test_stderr).to include filename
      end
    end

    context 'when enclosed file check is not skipped', doc_refs: ['Dim_loading_enclosedCheck'] do
      it 'returns error code with message when file is missing' do
        Test.main("check -i #{TEST_INPUT_DIR}/export_check/no_check_enclosed.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
      end
    end

    context 'when enclosed file check is skipped', doc_refs: ['Dim_loading_enclosedCheck'] do
      it 'returns success code even when file is missing' do
        Test.main("check -i #{TEST_INPUT_DIR}/export_check/no_check_enclosed.dim --no-check-enclosed")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
    end

    context 'when Dim file has custom attributes defined' do
      context "when custom attributes are provided with '-a' param while loading" do
        it 'returns success code', doc_refs: ['Dim_AttrFiles_Attribute'] do
          Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/test_module.dim -a #{TEST_INPUT_DIR}/with_custom_attributes/attributes.dim")
          expect(Dim::ExitHelper.exit_code).to eq 0
        end
      end

      context 'when custom attributes are not provided during loading' do
        let(:filename) { "#{TEST_INPUT_DIR}/custom_attributes_without_attributes_file/test_module.dim" }

        it 'exits process with meaningful message', doc_refs: ['Dim_AttrFiles_Attribute'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include("Error: in #{filename}: attribute necessary not allowed")
        end
      end
    end

    context 'when loading dim file with a empty document' do
      it 'shall throw an error with meaningful error message', doc_refs: ['Dim_loading_emptyDocument'] do
        Test.main("check -i #{TEST_INPUT_DIR}/document/empty_document.dim")

        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'document name must be a non-empty string'
      end
    end

    context 'when empty requirement is loaded' do
      it 'loads the requirement with default attributes', doc_refs: ['Dim_loading_readGood'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/empty_requirement/module.dim")
        req = loader.requirements['ESR_Test_empty']
        expect(req.type).to eq 'requirement'
      end
    end

    context 'when enclosed file contains absolute path' do
      it 'shall throw an error with meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/invalid_enclosed.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "'/module/valid_test_1.dim' must not be an absolute path"
      end
    end
  end
end
