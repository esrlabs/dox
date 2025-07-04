require_relative 'framework/helper'

module Dim
  describe 'Loading attributes file' do
    let(:loader) { Dim::Loader.new }

    context 'loading attributes in general' do
      context 'when type is not valid' do
        let(:attr_file) { "#{TEST_INPUT_DIR}/invalid_attributes/invalid_type.dim" }
        let(:err_msg) { "Error: in #{attr_file}: Invalid value \"multiple\" for type detected" }

        it 'aborts and prints meaningful message',
           doc_refs: %w[Dim_AttrFiles_Attribute Dim_ConfigFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/invalid_attributes/test_module.dim -a #{attr_file}")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(err_msg)
        end
      end

      context 'when default value is auto' do
        let(:attr_file) { "#{TEST_INPUT_DIR}/invalid_attributes/default_auto.dim" }
        let(:err_msg) { "Error: in #{attr_file}: Invalid value \"auto\" for default detected" }

        it 'exits process and prints meaningful message',
           doc_refs: %w[Dim_AttrFiles_Attribute Dim_ConfigFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/invalid_attributes/test_module.dim -a #{attr_file}")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(err_msg)
        end
      end

      context 'when default is not from allowed list of values' do
        let(:attr_file) { "#{TEST_INPUT_DIR}/invalid_attributes/invalid_default.dim" }
        let(:err_msg) { "Error: in #{attr_file}: default value for necessary must be from allowed list" }

        it 'exits process and prints meaningful message',
           doc_refs: %w[Dim_AttrFiles_Attribute Dim_ConfigFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/invalid_attributes/test_module.dim -a #{attr_file}")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(err_msg)
        end
      end

      context 'when allowed is not passed as an array list' do
        let(:attr_file) { "#{TEST_INPUT_DIR}/invalid_attributes/invalid_allowed.dim" }
        let(:err_msg) { "Error: in #{attr_file}: Invalid value \"red, green\" for allowed detected" }

        it 'exits process and prints meaningful message',
           doc_refs: %w[Dim_AttrFiles_Attribute Dim_ConfigFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/invalid_attributes/test_module.dim -a #{attr_file}")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include(err_msg)
        end
      end

      context 'when valid attributes file passed' do
        it 'loads custom attributes and prints the message',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/Config.dim")

          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stdout).to include('Loading [attributes] spec/test_input/with_custom_attributes/attributes.dim')
        end
      end

      context 'when valid attributes file passed along with silent option' do
        before { OPTIONS[:silent] = true }

        it 'does not print the attribute loading message',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/Config.dim")

          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stdout).not_to include('Loading [attributes] spec/test_input/with_custom_attributes/attributes.dim')
        end
      end
    end

    context 'loading custom attributes via config file' do
      context 'when valid custom attributes are defined' do
        let(:file) { "#{TEST_INPUT_DIR}/with_custom_attributes/Config.dim" }
        let(:requirement) { loader.requirements['test_id_1'] }

        it 'accepts the custom attributes provided by dim file',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          loader.load(file: file, allow_missing: false)
          expect(requirement.cluster).to eq('1.6.5')
          expect(requirement.necessary).to eq('false')
        end
      end

      context 'when attributes have invalid value for custom attributes' do
        let(:folder) { "#{TEST_INPUT_DIR}/with_custom_attributes/invalid_requirements" }
        let(:file) { "#{folder}/Config.dim" }

        it 'exits with error message', doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          expect { loader.load(file: file, silent: false) }.to raise_exception(SystemExit)
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{folder}/test_module.dim: attribute \"necessary\" must not be \"lorem\""
        end
      end

      context "when 'default' value for custom attributes is not from the 'allowed' list provided" do
        let(:file) { "#{TEST_INPUT_DIR}/with_custom_attributes/default_not_from_allowed_values/Config.dim" }

        it 'exits process with a meaningful message',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          expect { loader.load(file: file, silent: false) }.to raise_exception(SystemExit)
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include 'attributes.dim: default value for necessary must be from allowed list'
        end
      end

      context "when 'standard' attribute is added as a custom attribute" do
        it 'exits process with the meaningful message',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/attributes_file_with_standard_attributes/Config.dim")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include('attributes.dim: Defining standard attributes as a custom attributes is not allowed')
        end
      end

      context 'when empty attributes file is referenced' do
        it 'prints warning and skips the loading',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute] do
          Test.main("check -i #{TEST_INPUT_DIR}/empty_custom_attributes_file/Config.dim")

          expect(Dim::ExitHelper.exit_code).to be 0
          expect(@test_stdout).to include('Warning: empty file detected; skipped loading of attributes.dim')
        end
      end

      context 'when another attribute file is also passed using command line parameter' do
        context 'and both attributes file have unique attributes defined' do
          it 'loads custom attributes from both files and validates the requirements',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_CmdParam] do
            Test.main(
              "check -i #{TEST_INPUT_DIR}/with_custom_attributes/multiple_attribute_files/Config.dim " \
              "-a #{TEST_INPUT_DIR}/with_custom_attributes/multiple_attribute_files/custom_attributes.dim"
            )

            expect(Dim::ExitHelper.exit_code).to be 0
            expect(@test_stdout).to include("Done.\nChecking consistency...\nDone.")
          end
        end

        context 'and there is common attribute present in both attributes file' do
          let(:folder) { "#{TEST_INPUT_DIR}/with_custom_attributes/duplicate_attributes" }

          it 'loads custom attributes, but attributes from config file will be given priority',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_CmdParam] do
            Test.main(
              "check -i #{folder}/Config.dim " \
              "-a #{TEST_INPUT_DIR}/with_custom_attributes/duplicate_attributes/custom_attributes.dim"
            )

            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include("Error: in #{folder}/test_module.dim: attribute \"necessary\" must not be \"red\"")
          end
        end
      end

      context 'when attributes file is not referenced in Config' do
        let(:filename) { 'spec/test_input/custom_attributes_without_attributes_file/test_module.dim' }

        it 'does not search for attributes file till root director',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_SearchAttributeFile] do
          Test.main("check -i #{TEST_INPUT_DIR}/custom_attributes_without_attributes_file/Config.dim")

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include("Error: in #{filename}: attribute necessary not allowed")
        end
      end
    end

    context 'when loading without config file' do
      subject { loader.load(file: file, attributes_file: attributes_file) }
      context "when custom attributes file is passed using '-a' param with invalid filepath" do
        let(:file) { "#{TEST_INPUT_DIR}/with_custom_attributes/test_module.dim" }
        let(:attributes_file) { "#{TEST_INPUT_DIR}/with_custom_attribute/attributes.dim" }

        it 'raises file not found error',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_CmdParam] do
          expect { subject }.to raise_exception(Errno::ENOENT)
        end
      end

      context "when custom attributes file is passed using '-a' param with valid filepath" do
        let(:file) { "#{TEST_INPUT_DIR}/with_custom_attributes/test_module.dim" }
        let(:attributes_file) { "#{TEST_INPUT_DIR}/with_custom_attributes/attributes.dim" }

        it 'loads the dim file',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_CmdParam] do
          subject
          expect(loader.requirements['test_id_1'].cluster).to eq '1.6.5'
          expect(loader.requirements['test_id_1'].necessary).to eq 'false'
        end
      end

      context 'when custom attributes file not passed' do
        context 'when attributes file is present at same level as a requirements file' do
          it 'loads the attributes before processing the requirements',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_SearchAttributeFile] do
            Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/test_module.dim")

            expect(Dim::ExitHelper.exit_code).to be 0
            expect(@test_stdout).to include("Checking consistency...\nDone.")
          end
        end

        context 'when attributes file is present one or more level above requirements file' do
          it 'searches for attributes file till root directory and loads attributes if file present',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_SearchAttributeFile] do
            Test.main("check -i #{TEST_INPUT_DIR}/with_custom_attributes/reference_from_parent/test_module.dim")

            expect(Dim::ExitHelper.exit_code).to be 0
            expect(@test_stdout).to include("Checking consistency...\nDone.")
          end
        end

        context 'when attributes file is not present on same level or till root level' do
          let(:filename) { "#{TEST_INPUT_DIR}/custom_attributes_without_attributes_file/test_module.dim" }

          it 'exits process with a meaningful message',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_SearchAttributeFile] do
            Test.main("check -i #{filename}")

            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include("Error: in #{filename}: attribute necessary not allowed")
          end
        end

        context "when attributes file is present but not named as 'attributes.dim'" do
          let(:filename) { "#{TEST_INPUT_DIR}/custom_attributes_without_attributes_file/test_module.dim" }

          it 'exits process with a meaningful message',
             doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_AttrFiles_SearchAttributeFile] do
            Test.main("check -i #{filename}")

            expect(Dim::ExitHelper.exit_code).to be 1
            expect(@test_stderr).to include("Error: in #{filename}: attribute necessary not allowed")
          end
        end
      end
    end
  end
end
