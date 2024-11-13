require_relative 'framework/helper'

module Dim
  describe 'Properties file' do
    context 'with asil and cal attributes' do
      it 'shall resolve default-values',
         doc_refs: %w[Dim_ConfigFiles_Property Dim_PropFiles_Property Dim_ReqFiles_asil Dim_ReqFiles_calString] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/auto_asilCal_check/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 0

        expect(loader.requirements['test_id_asilNotSet'].data['asil']).to eql 'not_set'
        expect(loader.requirements['test_id_asilNone'].data['asil']).to eql 'ASIL_A'
        expect(loader.requirements['test_id_asilSet'].data['asil']).to eql 'ASIL_D'
        expect(loader.requirements['test_id_asilNotSet'].data['cal']).to eql 'not_set'
        expect(loader.requirements['test_id_asilNone'].data['cal']).to eql 'not_set'
        expect(loader.requirements['test_id_asilSet'].data['cal']).to eql 'QM'

        expect(loader.requirements['test_id_asilCalNotSet'].data['asil']).to eql 'not_set'
        expect(loader.requirements['test_id_asilCalNone'].data['asil']).to eql 'ASIL_B'
        expect(loader.requirements['test_id_asilCalSet'].data['asil']).to eql 'ASIL_D'
        expect(loader.requirements['test_id_asilCalNotSet'].data['cal']).to eql 'not_set'
        expect(loader.requirements['test_id_asilCalNone'].data['cal']).to eql 'CAL_4'
        expect(loader.requirements['test_id_asilCalSet'].data['cal']).to eql 'QM'

        expect(loader.requirements['test_id_noneNotSet'].data['asil']).to eql 'not_set'
        expect(loader.requirements['test_id_noneNone'].data['asil']).to eql 'not_set'
        expect(loader.requirements['test_id_noneSet'].data['asil']).to eql 'ASIL_D'
        expect(loader.requirements['test_id_noneNotSet'].data['cal']).to eql 'not_set'
        expect(loader.requirements['test_id_noneNone'].data['cal']).to eql 'not_set'
        expect(loader.requirements['test_id_noneSet'].data['cal']).to eql 'QM'
      end
    end

    context 'with references defined' do
      it 'shall be checked for consistency in context of the loaded configuration',
         doc_refs: %w[Dim_ConfigFiles_Property Dim_PropFiles_Property Dim_loading_checkCyclic
                      Dim_loading_checkMissing] do
        Test.main("check -i #{TEST_INPUT_DIR}/property_file_refs/Config_circular_reference.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include('"ref_test_module1_req1" is cyclically referenced: ref_test_module1_req1 -> ref_test_module2_req1 -> ref_test_module1_req1')
        expect(@test_stderr).to include('spec/test_input/property_file_refs/ref_test_module1.dim')

        Test.main("check -i #{TEST_INPUT_DIR}/property_file_refs/Config_invalid_reference.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include('"ref_test_module1_req1" refers to non-existing "ref_test_module1_req3"')
        expect(@test_stderr).to include('spec/test_input/property_file_refs/ref_test_module1.dim')
      end
    end

    # TODO: Remove this when test_setups is removed
    context 'when test_setups are defined' do
      it 'it also adds the value for verification_methods', doc_refs: [] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/property_file_insertion/test_setups/Config.dim")
        expect(loader.requirements['ID_empty_test_setups'].verification_methods).to eq ['off_target']
      end
    end

    context 'with dim attributes defined' do
      it 'shall resolve default-values and empty attributes of dim modules',
         doc_refs: %w[Dim_ConfigFiles_Property Dim_PropFiles_Property] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/property_file_insertion/Config.dim")
        expect(Dim::ExitHelper.exit_code).to be 0

        expect(loader.requirements['test_module_for_insertion_empty'].data['text']).to eql 'inserted text from properties file'
        expect(loader.requirements['test_module_for_insertion_empty'].data['asil']).to eql 'ASIL_B'
        expect(loader.requirements['test_module_for_insertion_empty'].data['verification_criteria']).to eql 'inserted verification criteria'
        expect(loader.requirements['test_module_for_insertion_empty'].data['cal']).to eql 'QM'
        expect(loader.requirements['test_module_for_insertion_empty'].data['feature']).to eql 'inserted_feature'
        expect(loader.requirements['test_module_for_insertion_empty'].data['change_request']).to eql 'inserted_CR'
        expect(loader.requirements['test_module_for_insertion_empty'].data['tags']).to eql 'legal, sys'
        expect(loader.requirements['test_module_for_insertion_empty'].data['developer']).to eql 'inserted developer'
        expect(loader.requirements['test_module_for_insertion_empty'].data['tester']).to eql 'inserted tester'
        expect(loader.requirements['test_module_for_insertion_empty'].data['test_setups']).to eql 'manual'
        expect(loader.requirements['test_module_for_insertion_empty'].data['verification_methods']).to eql 'manual'
        expect(loader.requirements['test_module_for_insertion_empty'].data['status']).to eql 'valid'
        expect(loader.requirements['test_module_for_insertion_empty'].data['review_status']).to eql 'rejected'
        expect(loader.requirements['test_module_for_insertion_empty'].data['comment']).to eql 'inserted comment'
        expect(loader.requirements['test_module_for_insertion_empty'].data['miscellaneous']).to eql 'inserted miscellaneous'
        expect(loader.requirements['test_module_for_insertion_empty'].data['sources']).to eql 'inserted sources'
        expect(loader.requirements['test_module_for_insertion_empty'].data['miscellaneous']).to eql 'inserted miscellaneous'
        expect(loader.requirements['test_module_for_insertion_empty'].data['refs']).to eql 'test_module_no_insertion_empty'

        expect(loader.requirements['test_module_for_insertion_not_empty'].data['text']).to eql 'test text'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['asil']).to eql 'QM'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['verification_criteria']).to eql 'test criteria'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['cal']).to eql 'CAL_4'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['feature']).to eql 'test_feature'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['change_request']).to eql 'test_CR'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['tags']).to eql 'swa'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['developer']).to eql 'test_developer'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['test_setups']).to eql 'none'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['verification_methods']).to eql 'none'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['status']).to eql 'invalid'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['review_status']).to eql 'unclear'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['comment']).to eql 'test_comment'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['miscellaneous']).to eql 'test_misc'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['sources']).to eql 'test_source'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['miscellaneous']).to eql 'test_misc'
        expect(loader.requirements['test_module_for_insertion_not_empty'].data['refs']).to eql 'test_module_for_insertion_empty'

        expect(loader.requirements['test_module_no_insertion_empty'].data['type']).to eql 'requirement'
        expect(loader.requirements['test_module_no_insertion_empty_text'].data['text']).to eql ''

        expect(loader.requirements['test_module_text_insertion_text'].data['text']).to eql 'test text'
        expect(loader.requirements['test_module_text_insertion_no_text'].data['text']).to eql "multi,\nline test\ntext from property\nfile!"
        expect(loader.requirements['test_module_text_insertion_no_text'].data['asil']).to eql 'ASIL_C'

        expect(loader.requirements['test_module_for_requirement_empty'].data['type']).to eq 'information'
        expect(loader.requirements['test_module_for_requirement_info'].data['type']).to eq 'information'
        expect(loader.requirements['test_module_for_requirement_req'].data['type']).to eq 'requirement'

        expect(loader.requirements['test_module_for_information_empty'].data['type']).to eq 'requirement'
        expect(loader.requirements['test_module_for_information_info'].data['type']).to eq 'information'
        expect(loader.requirements['test_module_for_information_req'].data['type']).to eq 'requirement'
      end
    end
  end
end
