require_relative 'framework/helper'

module Dim
  describe 'Consistency check' do
    context 'when loading correct input files' do
      it 'shall not lead to an error', doc_refs: ['Dim_check_General'] do
        Test.main("check -i #{TEST_INPUT_DIR}/export_check/Config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
    end

    context 'when loading a file which includes non-unique ids' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkID'] do
        Test.main("check -i #{TEST_INPUT_DIR}/same_id_same_file/Config.yml")
        expect(@test_stderr).to include('found "SameID" twice which must be unique')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'when loading different files which include non-unique ids' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkID'] do
        Test.main("check -i #{TEST_INPUT_DIR}/same_id_different_files/Config.yml")
        expect(@test_stderr).to include('Input2.yml: id "SameID" found more than once')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'when loading a single file which include requirements that are cyclically referenced' do
      let(:filename) { "#{TEST_INPUT_DIR}/cyclic_reference_same_file/test_module_1.dim" }

      it 'shall throw an error and print the cyclic reference stack', doc_refs: ['Dim_loading_checkCyclic'] do
        Test.main("check -i #{filename}")
        expect(@test_stderr).to include("Error: in #{filename}: \"test_id_1\" is cyclically referenced")
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'when loading files which include requirements that are cyclically referenced through different files' do
      let(:folder) { "#{TEST_INPUT_DIR}/cyclic_reference_different_modules" }

      it 'shall throw an error and print the cyclic reference stack', doc_refs: ['Dim_loading_checkCyclic'] do
        Test.main("check -i #{folder}/config.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include("Error: in #{folder}/test_module_1.dim: \"test_module_1-0000-0001\" is cyclically referenced: test_module_1-0000-0001 -> test_module_2-0000-0001 -> test_module_1-0000-0001")
      end
    end

    context 'when loading files which include requirements that have unresolved references with check subcommand but without --allow-missing' do
      let(:filename) { "#{TEST_INPUT_DIR}/missing_refs/test_module_1.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkMissing'] do
        Test.main("check -i #{filename}")
        expect(@test_stderr).to include("Error: in #{filename}: \"test_id_3\" refers to non-existing \"non_exist\"")
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'when loading files which include requirements that have unresolved references with check subcommand and --allow-missing' do
      it 'shall not lead to an error', doc_refs: ['Dim_loading_checkMissingDisable'] do
        Test.main("check -i #{TEST_INPUT_DIR}/missing_refs/test_module_1.dim  --allow_missing")
        expect(@test_stderr).not_to include('Error: "test_id_3" refers to non-existing "non_exist"')
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
    end

    context 'when loading files with same document but different category' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkDocument'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/same_module_different_category.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'Error: in spec/test_input/invalid_input/modules/valid_test_2.dim: files of the same document must have the same category:'
        expect(@test_stderr).to include '- spec/test_input/invalid_input/modules/valid_test_1.dim (system)'
        expect(@test_stderr).to include '- spec/test_input/invalid_input/modules/valid_test_2.dim (software)'
      end
    end

    context 'when loading files with same document but different owner' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkDocument'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/same_module_different_owner.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'Error: in spec/test_input/invalid_input/modules/valid_test_2.dim: files of the same document must have the same owner:'
        expect(@test_stderr).to include '- spec/test_input/invalid_input/modules/valid_test_1.dim (ABC)'
        expect(@test_stderr).to include '- spec/test_input/invalid_input/modules/valid_test_2.dim (DEF)'
      end
    end

    context 'when loading files with same document but multiple metadata' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_checkMetadata'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/duplicate_metadata.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'invalid_input/modules/duplicate_meta2.dim: only one metadata per document allowed'
      end
    end
  end
end
