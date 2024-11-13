require_relative 'framework/helper'

module Dim
  describe 'Loading a properties file' do
    context 'with an invalid attribute type' do
      let(:err_msg) { 'Error: in properties.yaml: The value for key asil in properties files must be a string' }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_PropFiles_Property'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_property/invalid_asil_value/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include err_msg
      end
    end

    context 'with non-allowed attribute value' do
      let(:err_msg) do
        'Error: in properties.yaml: The properties file includes an invalid asil value ' \
        "'ASIL_Y' for module: test_module_3."
      end

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_PropFiles_Property'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_property/invalid_asil_level/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include err_msg
      end
    end

    context 'with invalid YAML syntax' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_PropFiles_Property'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_property/invalid_file/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'Error: in properties.yaml:'
      end
    end

    context 'with empty yaml file' do
      it 'shall print warning message and skip file loading', doc_refs: ['Dim_PropFiles_Property'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_property/empty_property/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).to include('Warning: empty file detected; skipped loading of properties.yaml')
      end
    end
  end
end
