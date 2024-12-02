require_relative 'framework/helper'

module Dim
  describe 'Loading a config file' do
    context 'which is not empty but has invalid yaml syntax' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/yaml_syntax_invalid.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_loading_readBad'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'mapping values are not allowed in this context at line 3 column 23'
        expect(@test_stderr).to include filename
      end
    end

    context 'with int as originator' do
      it 'shall interpret the int as string', doc_refs: ['Dim_Syntax_Values'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/invalid_originator.dim")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).to include 'Loading [334]'
      end
    end

    context 'with invalid top-level attribute' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/invalid_config_toplevel_attribute.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Config'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'top level key in config file must be "Config", "Properties", "Attributes", found "Test"'
        expect(@test_stderr).to include filename
      end
    end

    context 'with a valid array of config entries' do
      it 'shall annotate requirements accordingly',
         doc_refs: %w[Dim_ConfigFiles_Config Dim_ConfigFiles_Files Dim_ConfigFiles_Originator
                      Dim_ConfigFiles_Category] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/export_check/Config.dim")
        req = loader.requirements['test_id_2']
        expect(req.origin).to eql('XY_Company')
        expect(req.category).to eql('module')
      end
    end

    context 'with invalid attribute in config entry' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/invalid_config_entry_attribute.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Config'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "each hash in 'Config' array must have key/value pairs for files, category, originator, disable_naming_convention_check."
        expect(@test_stderr).to include filename
      end
    end

    context 'with missing attribute in config entry' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/missing_config_entry_attribute.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Config'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "each hash in 'Config' array must have key/value pairs for files, category, originator, disable_naming_convention_check."
        expect(@test_stderr).to include "#{filename}"
      end
    end

    context 'with file pattern that does not match' do
      it 'shall not lead to an error but print a warning output', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/no_match_pattern.dim")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).to include 'no matches for "test*.dim'
      end
    end

    context 'with empty files attribute' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/files_key_invalid_string.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "attribute \"files\" of 'CompanyName' must not have an empty string"
        expect(@test_stderr).to include filename
      end
    end

    context 'where files is a hash not a string or array' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/hash_in_files.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include " attribute \"files\" of 'bla' reqs must be a string or an array of strings."
        expect(@test_stderr).to include filename
      end
    end

    context 'where files are specified twice' do
      it 'shall throw an error and display the correct error message', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/duplicate_files.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'file spec/test_input/invalid_input/modules/duplicate_module.dim already loaded'
      end
    end

    context 'where category has an invalid value' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/invalid_types.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Category'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "attribute \"category\" of 'Customer' reqs is 'test' but must be one of input, system, software, architecture, module."
        expect(@test_stderr).to include filename
      end
    end

    context 'with category as array instead of string' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/category_array.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Category'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "attribute \"category\" of 'CompanyName' reqs must be a string"
        expect(@test_stderr).to include filename
      end
    end

    context 'where Properties is not a string' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/properties_array.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Property'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "'Properties' must be a string"
        expect(@test_stderr).to include filename
      end
    end

    context 'with config as a simple string instead of an array of config entries' do
      let(:filename) { "#{TEST_INPUT_DIR}/invalid_input/config_string.dim" }

      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ConfigFiles_Config'] do
        Test.main("check -i #{filename}")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include "'Config' must be an array"
        expect(@test_stderr).to include filename
      end
    end

    context 'when backward slashes are detected in the filepath' do
      let(:pattern) { '.\modules\duplicate_module.dim' }

      it 'warns user about backward slashes' do
        Test.main("check -i #{TEST_INPUT_DIR}/invalid_input/backward_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).to include "Warning: Backward slashes detected in pattern #{pattern}. Use '/' over '\\'"
      end
    end

    context 'when absolute path is given' do
      let(:filepath) { "#{TEST_INPUT_DIR}/invalid_input/absolute_file_path.dim"}
      let(:pattern) { '/modules/test_module_1.dim' }

      it 'shall throw an error and print error message', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{filepath}")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include "Error: in #{filepath}: '#{pattern}' must not be an absolute path"
      end
    end

    context 'when parent dir path is added in filepath' do
      let(:filepath) { "#{TEST_INPUT_DIR}/invalid_input/parent_dir_in_path.dim" }
      let(:pattern) { 'modules/../test_module_1.dim' }

      it 'shall throw an error and show a message on console', doc_refs: ['Dim_ConfigFiles_Files'] do
        Test.main("check -i #{filepath}")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include "Error: in #{filepath}: '#{pattern}' must not include '..'"
      end
    end

    context 'when custom attributes are provided' do
      context "when 'Attributes' is of type string" do
        it 'loads config file along with custom attributes given', doc_refs: ['Dim_ConfigFiles_Attribute'] do
          loader = Dim::Loader.new
          loader.load(file: "#{TEST_INPUT_DIR}/with_custom_attributes/Config.dim")
          req_with_custom_attribute = loader.requirements['test_id_1']
          expect(req_with_custom_attribute.text).to eq('First Test Requirement')
          expect(req_with_custom_attribute.cluster).to eq('1.6.5')
          expect(req_with_custom_attribute.necessary).to eq('false')

          req_without_custom_attribute = loader.requirements['test_id_2']
          expect(req_without_custom_attribute.text).to eq('Second Test Requirement')
          expect(req_without_custom_attribute.cluster).to eq('')
          expect(req_without_custom_attribute.necessary).to eq('')
        end
      end

      context "when 'Attributes' is other than string" do
        let(:filepath) { "#{TEST_INPUT_DIR}/invalid_input/custom_attributes.dim" }
        let(:err_msg) { "Error: in #{filepath}: 'Attributes' must be a string" }

        it 'throws and exits with meaningful error message', doc_refs: ['Dim_ConfigFiles_Attribute'] do
          Test.main("check -i #{filepath}")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include err_msg
        end
      end

      context 'with dependencies within the categories even if circularly referenced' do
        it 'does not error out even if there is circular dependency within different levels',
            doc_refs: %w[Dim_api_upstreamRefs Dim_api_downstreamRefs Dim_loading_checkCyclic] do
              loader = Dim::Loader.new
              loader.load(file: "#{TEST_INPUT_DIR}/backward_reference_within_category/config.dim")

              expect(Dim::ExitHelper.exit_code).to eq 0
              expect(loader.requirements['SRS_requirement_1'].upstreamRefs).to match_array %w[SYS_requirement1 SRS_requirement_2]
              expect(loader.requirements['SRS_requirement_1'].downstreamRefs).to match_array ['SWA_requirement1']

              expect(loader.requirements['SRS_requirement_2'].upstreamRefs).to match_array []
              expect(loader.requirements['SRS_requirement_2'].downstreamRefs).to match_array %w[SRS_requirement_1 SWA_requirement1]

              expect(loader.requirements['SWA_requirement1'].upstreamRefs).to match_array %w[SRS_requirement_1 SRS_requirement_2 SYS_requirement1]
              expect(loader.requirements['SWA_requirement1'].downstreamRefs).to match_array []

              expect(loader.requirements['SWA_requirement2'].upstreamRefs).to match_array []
              expect(loader.requirements['SWA_requirement2'].downstreamRefs).to match_array []

              expect(loader.requirements['SMD_requirement1'].upstreamRefs).to match_array []
              expect(loader.requirements['SMD_requirement1'].downstreamRefs).to match_array []

              expect(loader.requirements['SMD_requirement2'].upstreamRefs).to match_array []
              expect(loader.requirements['SMD_requirement2'].downstreamRefs).to match_array []

              expect(loader.requirements['IN_requirement1'].upstreamRefs).to match_array []
              expect(loader.requirements['IN_requirement1'].downstreamRefs).to match_array []

              expect(loader.requirements['IN_requirement2'].upstreamRefs).to match_array []
              expect(loader.requirements['IN_requirement2'].downstreamRefs).to match_array []

              expect(loader.requirements['SYS_requirement1'].upstreamRefs).to match_array []
              expect(loader.requirements['SYS_requirement1'].downstreamRefs).to match_array %w[SRS_requirement_1 SWA_requirement1]

              expect(loader.requirements['SYS_requirement2'].upstreamRefs).to match_array []
              expect(loader.requirements['SYS_requirement2'].downstreamRefs).to match_array []
            end
      end

      context 'with dependencies within the same categories' do
        it 'when circularly referenced raises error with meaningful message', doc_refs: ['Dim_loading_checkCyclic'] do
          Test.main("check -i #{TEST_INPUT_DIR}/backward_reference_same_category/circular/config.dim")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include '"SRS_req_1" is cyclically referenced: SRS_req_1 -> SRS_req_2 -> SRS_req_3 -> SRS_req_1'
          expect(@test_stderr).to include 'backward_reference_same_category/circular/module1.dim'
        end

        it 'loads requirements with correctly referenced', doc_refs: ['Dim_ReqFiles_refs'] do
          Test.main("check -i #{TEST_INPUT_DIR}/backward_reference_same_category/non_circular/config.dim")

          expect(Dim::ExitHelper.exit_code).to be 0
        end
      end
    end

    context 'when software files mentioned' do
      let(:warning) { "Warning: disable_naming_convention_check attribute will only take effect when category is software" }

      context 'when category is software' do
        it 'does not put a warning or error out the execution', doc_refs: ['Dim_ConfigFiles_disableNameCheck'] do
          Test.main("check -i #{TEST_INPUT_DIR}/software_configs/with_category_software/config.dim")
          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stderr).not_to include(warning)
          expect(@test_stdout).to include('Done')
        end
      end

      context 'when category is other than software' do
        it 'loads Dim files with a warning', doc_refs: ['Dim_ConfigFiles_disableNameCheck'] do
          Test.main("check -i #{TEST_INPUT_DIR}/software_configs/config.dim")

          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stderr).to include(warning)
          expect(@test_stdout).to include('Done')
        end
      end

      context 'when category is software but legacy is not set' do
        let(:filepath) { "#{TEST_INPUT_DIR}/software_configs/with_category_software" }

        it 'sets legacy to false as default', doc_refs: ['Dim_ConfigFiles_disableNameCheck'] do
          Test.main("check -i #{filepath}/without_name_check_config.dim")
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include('ID ESR-0001 in software requirement must start with "SRS_"')
          expect(@test_stderr).to include("#{filepath}/test_module.dim")
        end
      end

      context 'when category is software and legacy is no' do
        let(:filepath) { "#{TEST_INPUT_DIR}/software_configs/with_category_software" }

        it 'throws an error and exits', doc_refs: ['Dim_ConfigFiles_disableNameCheck'] do
          Test.main("check -i #{filepath}/with_name_check_no_config.dim")
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).not_to include('Legacy in config must be either boolean value or a string "yes" or "no"')
          expect(@test_stderr).to include('ID ESR-0001 in software requirement must start with "SRS_"')
          expect(@test_stderr).to include("#{filepath}/test_module.dim")
        end
      end

      context 'when category is software but legacy is other than "yes" or "no"' do
        let(:filepath) { "#{TEST_INPUT_DIR}/software_configs/with_category_software/invalid_name_check_config.dim" }

        it 'throws error and exits', doc_refs: ['Dim_ConfigFiles_disableNameCheck'] do
          Test.main("check -i #{filepath}")
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include('disable_naming_convention_check in config must be either boolean value or a string "yes" or "no"')
          expect(@test_stderr).to include(filepath)
        end
      end
    end

    context 'with software requirements' do
      subject { Test.main("check -i #{TEST_INPUT_DIR}/software_requirements/#{filepath}/config.dim") }

      context 'when category is not software' do
        let(:filepath) { 'without_software_category' }

        it 'does not throw error and loads the requirements', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stdout).to include('Done')
        end
      end

      context 'when legacy is set to "yes"' do
        let(:filepath) { 'legacy' }

        it 'does not throws error and loads requirements', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stdout).to include('Done')
        end
      end

      context 'when requirement does not start with "SRS"' do
        let(:filepath) { 'start_without_srs' }

        it 'throws meaningful error and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(
            'ID feature-1_aspect-1 in software requirement must start with "SRS_"'
          )
        end
      end

      context 'when more than two underscores are present' do
        let(:filepath) { 'multiple_underscores' }

        it 'throws error and aborts loading', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(
            'ID SRS_feature-1_aspect-1_wrong in software requirement must contain exactly two "_"'
          )
        end
      end

      context 'when aspect is missing or empty' do
        let(:filepath) { 'missing_aspect' }

        it 'throws error and aborts loading', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(
            'invalid ID SRS_feature_ in software requirement; missing aspect/ratio after "SRS_feature'
          )
        end
      end

      context 'when feature is missing' do
        let(:filepath) { 'missing_feature' }

        it 'throws error and exit the process', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(
            'invalid ID SRS__aspect in software requirement; missing feature after "SRS_"'
          )
        end
      end

      context 'when ID only contains "SRS"' do
        let(:filepath) { 'only_srs' }

        it 'throws error with meaningful message and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(
            'invalid ID SRS_ in software requirement; missing feature after "SRS_"'
          )
        end
      end

      context 'when document name contains multiple underscores' do
        let(:filepath) { 'module_with_multiple_underscores' }

        it 'throws error with meaningful message and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include(
            'document SRS_feature_aspect in software requirement; must contain exactly one "_"'
          )
        end
      end

      context 'when document name is missing feature' do
        let(:filepath) { 'module_without_feature' }

        it 'throws error with meaningful message and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include(
            'document SRSFeature in software requirement must start with "SRS_"'
          )
        end
      end

      context 'when document name does not start with SRS' do
        let(:filepath) { 'module_without_srs' }

        it 'throws error with meaningful message and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
          subject
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include(
            'document SRSFeature_feature in software requirement must start with "SRS_"'
          )
        end
      end

      context 'when non-alphanumeric characters are present' do
        context 'in feature' do
          let(:filepath) { 'non_alphanumeric_in_feature' }

          it 'throws error and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
            subject
            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include(
              'feature in ID SRS_feature@-1_aspect-1 in software requirement ' \
                'contains non-alphanumeric characters'
            )
          end
        end

        context 'in aspect' do
          let(:filepath) { 'non_alphanumeric_in_aspect' }

          it 'throws meaningful error and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
            subject
            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include(
              'aspect in ID SRS_feature-1_aspect#-1 in software requirement ' \
                'contains non-alphanumeric characters'
            )
          end
        end

        context 'in document name' do
          let(:filepath) { 'module_with_invalid_chars' }

          it 'throws meaningful error and exits', doc_refs: ['Dim_ConfigFiles_SRS'] do
            subject
            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include(
              'feature in document SRS_feature#1 in software requirement contains non-alphanumeric characters'
            )
          end
        end
      end
    end
  end
end
