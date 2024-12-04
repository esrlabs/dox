require_relative 'framework/helper'

# rubocop:disable Metric/BlockLength, Layout/LineLength
module Dim
  describe 'Requirements file attribute' do
    context 'document' do
      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/document/invalid_type.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_document'] do
            Test.main("check -i #{filename}")
            expect(Dim::ExitHelper.exit_code).to eq 1
            expect(@test_stderr).to include "Error: in #{filename}: document name must be a non-empty string"
          end
      end

      context 'when value string is empty' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/document/empty.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_document'] do
            Test.main("check -i #{filename}")
            expect(Dim::ExitHelper.exit_code).to eq 1
            expect(@test_stderr).to include "Error: in #{filename}: document name must be a non-empty string"
          end
      end

      it 'shall default to the folder name of the requirements file', doc_refs: ['Dim_ReqFiles_document'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/document/default.dim")
        expect(loader.requirements['ID_0'].document).to eq('module')
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      it 'shall be non-unique', doc_refs: ['Dim_ReqFiles_document'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/document/config.dim")
        expect(loader.requirements['ID_1'].document).to eq('Name1')
        expect(loader.requirements['ID_2'].document).to eq('Name1')
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      context 'when document is missing' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/document/without_module.dim" }

        it 'shall throw an error', doc_refs: ['Dim_ReqFiles_MissingDocument'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: Document name is missing; please add document name"
        end
      end
    end

    context 'enclosed' do
      it 'shall be a string or an array of strings', doc_refs: ['Dim_ReqFiles_enclosed'] do
        Test.main("export -i #{TEST_INPUT_DIR}/reqs/enclosed/string.dim -o #{TEST_OUTPUT_DIR}/out_string -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(File.exist?("#{TEST_OUTPUT_DIR}/out_string/enclosed/data/a.txt")).to be true
        Test.main("export -i #{TEST_INPUT_DIR}/reqs/enclosed/array.dim -o #{TEST_OUTPUT_DIR}/out_array -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(File.exist?("#{TEST_OUTPUT_DIR}/out_array/enclosed/data/b.txt")).to be true
        expect(File.exist?("#{TEST_OUTPUT_DIR}/out_array/enclosed/data/c.txt")).to be true
      end

      it 'shall be a optional', doc_refs: ['Dim_ReqFiles_enclosed'] do
        Test.main("export -i #{TEST_INPUT_DIR}/reqs/enclosed/default.dim -o #{TEST_OUTPUT_DIR}/out_default -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        files = Dir.glob("#{TEST_OUTPUT_DIR}/out_default/enclosed/**/*")
        # only Requirements.rst means no additional files
        expect(files.length).to be 1
        expect(files[0]).to include('Requirements.rst')
      end

      context 'when file does not exists' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/enclosed/notexist.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_enclosed'] do
            Test.main("check -i #{filename}")
            expect(Dim::ExitHelper.exit_code).to eq 1
            expect(@test_stderr).to include 'module_non_existing.dim" in "enclosed" does not refer to any existing file'
            expect(@test_stderr).to include filename
          end
      end

      context 'when string is empty' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/enclosed/empty_string.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_enclosed'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: \"enclosed\" must be a non-empty string or an array of non-empty strings"
        end
      end

      context 'when string includes ".."' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/enclosed/dotdot.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_enclosed'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: '../enclosed/dotdot.dim' must not include '..'"
        end
      end

      context 'when file path contains the superfluous characters' do
        let(:file_path) { "#{TEST_INPUT_DIR}/reqs/enclosed/dot.dim" }
        let(:loader) { Dim::Loader.new }

        it 'removes from file path' do
          loader.load(file: file_path)
          expect(loader.module_data['enclosed'][:files][file_path]).to match_array ['dot.dim']
        end
      end

      context 'when enclosed files uses backward slash in filepath' do
        let(:file_path) { "#{TEST_INPUT_DIR}/reqs/enclosed/backward.dim" }
        let(:loader) { Dim::Loader.new }
        let(:err) do
          "Warning: Backward slashes detected in filepath .\\data\\a.txt. Use '/' over '\\' in filepath"
        end

        it 'warns user about backward slash in the filepath' do
          loader.load(file: file_path)
          expect(Dim::ExitHelper.exit_code).to eq 0
          expect(@test_stdout).to include err
        end
      end
    end

    context 'metadata' do
      it 'shall be an optional string', doc_refs: ['Dim_ReqFiles_metadata'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/metadata/default.dim")
        expect(loader.metadata['Name1']).to eq('')
        expect(Dim::ExitHelper.exit_code).to eq 0
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/metadata/data.dim")
        expect(loader.metadata['Name1']).to eq("Test\nABC")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      context 'when value is not a string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/metadata/invalid_type.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_metadata'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: metadata must be a string"
        end
      end
    end

    context 'id' do
      it 'in regular form is a key of a collection of key/values pairs of strings',
         doc_refs: ['Dim_ReqFiles_regularYaml'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/id/invalid_value.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "CompanyName" must be String not Hash'
        expect(@test_stderr).to include 'reqs/id/invalid_value.dim'

        Test.main("check -i #{TEST_INPUT_DIR}/reqs/id/invalid_key.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attributes for id "test_id" must be key-value pairs'
        expect(@test_stderr).to include 'reqs/id/invalid_key.dim'
      end

      context 'when in short form is a key of a key/value pair of strings' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/id/invalid_short.dim" }

        it 'throws error and prints meaningful error message', doc_refs: ['Dim_ReqFiles_shortYaml'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include 'Invalid short-form in requirement "test_key", valid forms are "h<level> <text>" or "info <text>"'
          expect(@test_stderr).to include filename
        end
      end

      it 'without any data shall be accepted without errors', doc_refs: ['Dim_ReqFiles_id'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/id/only_id.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      it 'not specified (no requirements) shall not lead to an error', doc_refs: ['Dim_ReqFiles_id'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/id/empty.dim")
        expect(loader.requirements.length).to be 0
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      context 'when ","' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/id/comma.dim" }

        it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_ReqFiles_id'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include("Error: in #{filename}: Disallowed ',' found in id \"ESR_Test,1\"")
        end
      end
    end

    context 'type' do
      it 'shall be requirement, information and heading_0 to heading_100', doc_refs: ['Dim_ReqFiles_type'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/type/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_r'].type).to eq('requirement')
        expect(loader.requirements['id_i'].type).to eq('information')
        expect(loader.requirements['id_h0'].type).to eq('heading_0')
        expect(loader.requirements['id_h1'].type).to eq('heading_1')
        expect(loader.requirements['id_h100'].type).to eq('heading_100')
      end

      it 'requirement shall be the default', doc_refs: ['Dim_ReqFiles_type'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/type/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].type).to eq('requirement')
      end

      it 'unknown shall throw an error and print a meaningful error message', doc_refs: ['Dim_ReqFiles_type'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/type/unknown.dim")
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include 'attribute "type" must not be "unknown" (id: ID_unknown). "type" must be exactly one of "requirement", "information", "heading_<level>". Default is "requirement".'
      end

      it 'empty string shall throw an error and print a meaningful error message', doc_refs: ['Dim_ReqFiles_type'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/type/empty.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'attribute "type" must not be "" (id: ID_T1). "type" must be exactly one of "requirement", "information", "heading_<level>". Default is "requirement".'
      end

      it 'heading level too high shall throw an error and print a meaningful error message',
         doc_refs: ['Dim_ReqFiles_type'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/type/heading101.dim")
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include 'heading level above 100 is not allowed and makes absolutely no sense: heading'
      end

      it 'shall be h0 to h100 and info in short form',
         doc_refs: %w[Dim_ReqFiles_shortHeadingForm Dim_ReqFiles_shortInfoForm] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/type/valid_short.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['test_id_h0'].type).to eq('heading_0')
        expect(loader.requirements['test_id_h1'].type).to eq('heading_1')
        expect(loader.requirements['test_id_h100'].type).to eq('heading_100')
        expect(loader.requirements['test_id_info'].type).to eq('information')
      end
    end

    context 'text' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_text'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_singleLine'].text).to eq('Single line')
        expect(loader.requirements['ID_multiLine'].text).to eq("Multi\nline")
        expect(loader.requirements['ID_empty'].text).to eq('')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_text'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_default'].text).to eq('')
      end

      it 'shall be the rest after h0 to h100 and info in short form',
         doc_refs: %w[Dim_ReqFiles_shortHeadingForm Dim_ReqFiles_shortInfoForm] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text/valid_short.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['test_id_h0'].text).to eq('H0')
        expect(loader.requirements['test_id_h1'].text).to eq('H1')
        expect(loader.requirements['test_id_h100'].text).to eq('H100')
        expect(loader.requirements['test_id_info'].text).to eq("Short\ninformation")
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/text/no_string.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_text'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"text\" must be String not Array"
        end
      end
    end

    context 'verification_criteria' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_verificationCriteria'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vc/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v'].verification_criteria).to eq('This is a VC.')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_verificationCriteria'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vc/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].verification_criteria).to eq('')
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/vc/invalid_type.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_verificationCriteria'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"verification_criteria\" must be String not Array"
        end
      end
    end

    context 'feature' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_feature'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/feature/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v'].feature).to eq('This is a feature.')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_feature'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/feature/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].feature).to eq('')
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/feature/invalid_type.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_feature'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"feature\" must be String not Array"
        end
      end
    end

    context 'change_request' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_changeRequest'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/cr/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v'].change_request).to eq('This is a CR.')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_changeRequest'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/cr/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].change_request).to eq('')
      end

      context 'value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/cr/invalid_type.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_changeRequest'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"change_request\" must be String not Array"
        end
      end
    end

    context 'tags' do
      it 'shall be a comma separated string', doc_refs: ['Dim_ReqFiles_tags'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tags_attr/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].tags).to match_array(['memory'])
        expect(loader.requirements['id_v2'].tags).to include('covered')
        expect(loader.requirements['id_v2'].tags).to include('swa')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_tags'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tags_attr/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].tags).to eq([])
      end

      it 'shall throw an error and print a meaningful error message',
         doc_refs: ['Dim_ReqFiles_tags'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/tags_attr/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "tags" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/tags_attr/invalid_type.dim:'
      end

      it 'with duplicates shall not throw an error but duplicates are removed', doc_refs: ['Dim_ReqFiles_tags'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tags_attr/duplicate.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_duplicate'].tags).to match_array(%w[memory covered])
      end

      it 'shall not throw an error if an unknown tag is used',
         doc_refs: ['Dim_ReqFiles_tags'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/tags_attr/unknown.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).to include 'Done.'
      end
    end

    context 'asil' do
      it 'shall be a predefined string', doc_refs: ['Dim_ReqFiles_asil'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/asil/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].asil).to eq('QM')
        expect(loader.requirements['id_v2'].asil).to eq('QM(A)')
        expect(loader.requirements['id_v3'].asil).to eq('ASIL_D')
        expect(loader.requirements['id_v4'].asil).to eq('not_set')
        expect(loader.requirements['id_v5'].asil).to eq('not_set')
      end

      it 'shall be default=not_set if not specified', doc_refs: ['Dim_ReqFiles_asil'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/asil/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].asil).to eq('not_set')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_asil'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/asil/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "asil" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/asil/invalid_type.dim:'
      end

      it 'shall throw an error and print a meaningful error message if value is an empty string',
         doc_refs: ['Dim_ReqFiles_asil'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/asil/empty.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "asil" must not be "" (id: id_e). "asil" must be exactly one of "not_set",'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/asil/empty.dim:'
      end
    end

    context 'cal' do
      it 'shall be a predefined string', doc_refs: ['Dim_ReqFiles_calString'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/cal/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].cal).to eq('CAL_4')
        expect(loader.requirements['id_v2'].cal).to eq('QM')
        expect(loader.requirements['id_v3'].cal).to eq('not_set')
        expect(loader.requirements['id_v4'].cal).to eq('not_set')
      end

      it 'shall be not_set if not specified', doc_refs: ['Dim_ReqFiles_calString'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/cal/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].cal).to eq('not_set')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_calString'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/cal/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "cal" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/cal/invalid_type.dim:'
      end

      it 'shall throw an error and print a meaningful error message if value is an empty string',
         doc_refs: ['Dim_ReqFiles_calString'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/cal/empty.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "cal" must not be "" (id: id_e). "cal" must be exactly one of "QM", "CAL_1", "CAL_2", "CAL_3", "CAL_4", "not_set". Default is "not_set"'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/cal/empty.dim'
      end
    end

    context 'developer' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_developer'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/developer/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].developer).to eq(['Hallo'])
        expect(loader.requirements['id_v2'].developer).to eq([])
        expect(loader.requirements['id_v3'].developer).to eq(["A\nB"])
      end

      it 'shall resolve if missing', doc_refs: ['Dim_ReqFiles_developer'] do
        # category set (config loaded)
        lc = Dim::Loader.new
        lc.load(file: "#{TEST_INPUT_DIR}/reqs/developer/resolve_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lc.requirements['input_r'].developer).to eql []
        expect(lc.requirements['input_i'].developer).to eql []
        expect(lc.requirements['module_r'].developer).to eql ['CompanyName']
        expect(lc.requirements['module_i'].developer).to eql []
        # category unspecified
        lm = Dim::Loader.new
        lm.load(file: "#{TEST_INPUT_DIR}/reqs/developer/resolve_module.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lm.requirements['module_r'].developer).to eql []
        expect(lm.requirements['module_i'].developer).to eql []
      end

      it 'shall be not_set by default', doc_refs: ['Dim_ReqFiles_developer'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/developer/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].developer).to eq []
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/developer/default_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].developer).to eq ['CompanyName']
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_developer'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/developer/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "developer" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/developer/invalid_type.dim:'
      end
    end

    context 'tester' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_tester'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tester/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].tester).to eq ['Hallo']
        expect(loader.requirements['id_v2'].tester).to eq []
        expect(loader.requirements['id_v3'].tester).to eq ["A\nB"]
      end

      it 'shall resolve if not preset', doc_refs: ['Dim_ReqFiles_tester'] do
        # category set (config loaded)
        lc = Dim::Loader.new
        lc.load(file: "#{TEST_INPUT_DIR}/reqs/tester/resolve_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lc.requirements['input_r'].tester).to eql []
        expect(lc.requirements['input_i'].tester).to eql []
        expect(lc.requirements['module_r'].tester).to eql ['CompanyName']
        expect(lc.requirements['module_i'].tester).to eql []
        # category unspecified
        lm = Dim::Loader.new
        lm.load(file: "#{TEST_INPUT_DIR}/reqs/tester/resolve_module.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lm.requirements['module_r'].tester).to eql []
        expect(lm.requirements['module_i'].tester).to eql []
      end

      it 'shall be not_set by default', doc_refs: ['Dim_ReqFiles_tester'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tester/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].tester).to eq []
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/tester/default_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].tester).to eq ['CompanyName']
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_tester'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/tester/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "tester" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/tester/invalid_type.dim:'
      end
    end

    context 'verification_methods' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vm/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].verification_methods).to eq ['none']
        expect(loader.requirements['id_v2'].verification_methods).to match_array(%w[off_target on_target manual])
      end

      it 'shall resolve default', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        # category set (config loaded)
        lc = Dim::Loader.new
        lc.load(file: "#{TEST_INPUT_DIR}/reqs/vm/resolve_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lc.requirements['input_r'].verification_methods).to eql ['none']
        expect(lc.requirements['input_i'].verification_methods).to eql ['none']
        expect(lc.requirements['input_p'].verification_methods).to eql ['none']
        expect(lc.requirements['input_t'].verification_methods).to eql ['none']
        expect(lc.requirements['module_r'].verification_methods).to eql ['off_target']
        expect(lc.requirements['module_i'].verification_methods).to eql ['none']
        expect(lc.requirements['module_p'].verification_methods).to eql ['none']
        expect(lc.requirements['module_t'].verification_methods).to eql ['off_target']
        expect(lc.requirements['software_r'].verification_methods).to eql ['on_target']
        expect(lc.requirements['software_i'].verification_methods).to eql ['none']
        expect(lc.requirements['software_p'].verification_methods).to eql ['none']
        expect(lc.requirements['software_t'].verification_methods).to eql ['off_target']
        # category unspecified
        lm = Dim::Loader.new
        lm.load(file: "#{TEST_INPUT_DIR}/reqs/vm/resolve_module.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lm.requirements['module_r'].verification_methods).to eql ['none']
        expect(lm.requirements['module_i'].verification_methods).to eql ['none']
        expect(lm.requirements['module_p'].verification_methods).to eql ['none']
        expect(lm.requirements['module_t'].verification_methods).to eql ['none']
        ls = Dim::Loader.new
        ls.load(file: "#{TEST_INPUT_DIR}/reqs/vm/resolve_software.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(ls.requirements['software_r'].verification_methods).to eql ['none']
        expect(ls.requirements['software_i'].verification_methods).to eql ['none']
        expect(ls.requirements['software_p'].verification_methods).to eql ['none']
        expect(ls.requirements['software_t'].verification_methods).to eql ['none']
      end

      it 'shall be nil by default', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vm/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].verification_methods).to eq ['none']
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vm/default_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].verification_methods).to eq ['off_target']
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/vm/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "verification_methods" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/vm/invalid_type.dim:'
      end

      it 'with duplicates shall not throw an error but duplicates are removed', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vm/duplicate.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_duplicate'].verification_methods).to match_array(%w[off_target on_target])
      end

      it 'unknown shall throw an error and print a meaningful error message', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/vm/unknown.dim")
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include ' attribute "verification_methods" is invalid: "unknown" (id: id_unknown). "verification_methods" must be one or more of "none", "off_target", "on_target", "manual".'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/vm/unknown.dim:'
      end

      it 'shall throw error when empty value is set', doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/vm/empty.dim")
        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include 'attribute "verification_methods" is invalid: "" (id: id_d). "verification_methods" must be one or more of "none", "off_target", "on_target", "manual".'
      end

      it 'shall throw an error and print a meaningful error message if none is used with another enum value',
         doc_refs: ['Dim_ReqFiles_verificationMethods'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/vm/combined_none.dim")
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include "verification_methods for \"test_id_1\" can't include 'none' along with on_target"
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/vm/combined_none.dim:'
      end
    end

    context 'status' do
      it 'shall be a predefined string', doc_refs: ['Dim_ReqFiles_status'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/status/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_draft'].status).to eq('draft')
        expect(loader.requirements['id_valid'].status).to eq('valid')
        expect(loader.requirements['id_invalid'].status).to eq('invalid')
      end

      it 'shall resolve if missing', doc_refs: ['Dim_ReqFiles_status'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/status/resolve.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_r'].status).to eq('draft')
        expect(loader.requirements['id_i'].status).to eq('draft')
        expect(loader.requirements['id_h'].status).to eq('valid')
      end

      it 'shall resolve as default nil', doc_refs: ['Dim_ReqFiles_status'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/status/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_r'].status).to eq('draft')
        expect(loader.requirements['id_i'].status).to eq('draft')
        expect(loader.requirements['id_h'].status).to eq('valid')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_status'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/status/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "status" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/status/invalid_type.dim:'
      end

      it 'shall throw an error and print a meaningful error message if value is an empty string',
         doc_refs: ['Dim_ReqFiles_status'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/status/empty.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "status" must not be "" (id: id_empty). "status" must be exactly one of "valid",'
      end

      it 'shall throw an error and print a meaningful error message if value is unknown',
         doc_refs: ['Dim_ReqFiles_status'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/status/unknown.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "status" must not be "unknown" (id: id_unknown). "status" must be exactly one of "valid",'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/status/unknown.dim:'
      end
    end

    context 'review_status' do
      it 'shall be a predefined string', doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/rs/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_accepted'].review_status).to eq('accepted')
        expect(loader.requirements['id_rejected'].review_status).to eq('rejected')
        expect(loader.requirements['id_unclear'].review_status).to eq('unclear')
        expect(loader.requirements['id_not_reviewed'].review_status).to eq('not_reviewed')
        expect(loader.requirements['id_not_relevant'].review_status).to eq('not_relevant')
      end

      it 'shall resolve if not added', doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        lm = Dim::Loader.new
        lm.load(file: "#{TEST_INPUT_DIR}/reqs/rs/resolve_module.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lm.requirements['module_r'].review_status).to eq('not_reviewed')
        lc = Dim::Loader.new
        lc.load(file: "#{TEST_INPUT_DIR}/reqs/rs/resolve_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lc.requirements['input_r'].review_status).to eq('not_reviewed')
        expect(lc.requirements['module_r'].review_status).to eq('accepted')
      end

      it 'shall not_set as default not_set', doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        lm = Dim::Loader.new
        lm.load(file: "#{TEST_INPUT_DIR}/reqs/rs/default_module.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lm.requirements['module_r'].review_status).to eq('not_reviewed')
        lc = Dim::Loader.new
        lc.load(file: "#{TEST_INPUT_DIR}/reqs/rs/default_config.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(lc.requirements['input_r'].review_status).to eq('not_reviewed')
        expect(lc.requirements['module_r'].review_status).to eq('accepted')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/rs/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "review_status" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/rs/invalid_type.dim:'
      end

      it 'shall throw an error and print a meaningful error message if value is an empty string',
         doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/rs/empty.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "review_status" must not be "" (id: id_empty). "review_status" must be exactly one of "accepted",'
      end

      it 'shall throw an error and print a meaningful error message if value is unknown',
         doc_refs: ['Dim_ReqFiles_reviewStatus'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/rs/unknown.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'attribute "review_status" must not be "unknown" (id: id_unknown). "review_status" must be exactly one of "accepted",'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/rs/unknown.dim:'
      end
    end

    context 'comment' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_comment'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/comment/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v'].comment).to eq('This is a comment.')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_comment'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/comment/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].comment).to eq('')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_comment'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/comment/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "comment" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/comment/invalid_type.dim:'
      end
    end

    context 'miscellaneous' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_miscellaneous'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/misc/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v'].miscellaneous).to eq('This is a miscellaneous.')
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_miscellaneous'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/misc/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].miscellaneous).to eq('')
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_miscellaneous'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/misc/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "miscellaneous" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/misc/invalid_type.dim:'
      end
    end

    context 'sources' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_sources'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/sources/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].sources).to match_array(%w[a.cpp])
        expect(loader.requirements['id_v2'].sources).to match_array(%w[a.cpp b.cpp])
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_sources'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/sources/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].sources).to eq []
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_sources'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/sources/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "sources" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/sources/invalid_type.dim:'
      end

      it 'with duplicates shall not throw an error but duplicates are removed', doc_refs: ['Dim_ReqFiles_sources'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/sources/duplicate.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].sources).to match_array(%w[b.cpp a.cpp])
      end
    end

    context 'refs' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_refs'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/refs/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_v1'].refs).to match_array(%w[id_v3])
        expect(loader.requirements['id_v2'].refs).to match_array(%w[id_v3 id_v1])
      end

      it 'shall be an empty string if not specified', doc_refs: ['Dim_ReqFiles_refs'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/refs/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].refs).to eq []
      end

      it 'shall throw an error and print a meaningful error message if value is no string',
         doc_refs: ['Dim_ReqFiles_refs'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/refs/invalid_type.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include 'value of attribute "refs" must be String not Array'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/refs/invalid_type.dim:'
      end

      it 'with duplicates shall not throw an error but duplicates are removed', doc_refs: ['Dim_ReqFiles_refs'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/refs/duplicate.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['id_d'].refs).to match_array(%w[id_v3 id_v2])
      end

      it 'with references to non-existing requirements shall throw an error and print a meaningful error message',
         doc_refs: ['Dim_ReqFiles_refs'] do
        Test.main("check -i #{TEST_INPUT_DIR}/reqs/refs/unresolved.dim")
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include '"id_v1" refers to non-existing "id_v2"'
        expect(@test_stderr).to include 'Error: in spec/test_input/reqs/refs/unresolved.dim:'
      end
    end

    context 'when heading method is called on the requirement object' do
      it 'shall return the heading_1 when heading is called on the requirements object', doc_refs: ['Dim_ReqFiles_type'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/language/module_ok.dim")
        req = loader.requirements['ESR_Test_1']

        expect(req.heading_2).to eq 'heading_2'
      end
    end

    context 'language variants of text' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text_lang/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ESR_Test_1'].text).to eq("juhu\njuhu")
        expect(loader.requirements['ESR_Test_1'].text_spanish).to eq('ole')
        expect(loader.requirements['ESR_Test_2'].text).to eq('mist')
        expect(loader.requirements['ESR_Test_2'].text_english).to eq('damn')
        expect(loader.requirements['ESR_Test_3'].text).to eq('achso')
        expect(loader.requirements['ESR_Test_3'].text_french).to eq('')
      end

      it 'shall be an empty string if not specified in this particular requirement but specified in another requirement',
         doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text_lang/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_default1'].text_german).to eq('')
        expect(loader.requirements['ID_default1'].text_french).to eq('bla')
        expect(loader.requirements['ID_default2'].text_german).to eq('')
        expect(loader.requirements['ID_default2'].text_french).to eq('')

        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/text_lang/not_specified.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_not'].respond_to?('text_german')).to be(true)
        expect(loader.requirements['ID_not'].respond_to?('text_english')).to be(false)
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/text_lang/no_string.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_language'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"text_german\" must be String not Array"
        end
      end
    end

    context 'when language variants of verification_criteria' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vc_lang/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ESR_Test_1'].verification_criteria).to eq("juhu\njuhu")
        expect(loader.requirements['ESR_Test_1'].verification_criteria_spanish).to eq('ole')
        expect(loader.requirements['ESR_Test_2'].verification_criteria).to eq('mist')
        expect(loader.requirements['ESR_Test_2'].verification_criteria_english).to eq('damn')
        expect(loader.requirements['ESR_Test_3'].verification_criteria).to eq('achso')
        expect(loader.requirements['ESR_Test_3'].verification_criteria_french).to eq('')
      end

      it 'shall be an empty string if not specified in this particular requirement but specified in another requirement',
         doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vc_lang/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_default1'].verification_criteria_german).to eq('')
        expect(loader.requirements['ID_default1'].verification_criteria_french).to eq('bla')
        expect(loader.requirements['ID_default2'].verification_criteria_german).to eq('')
        expect(loader.requirements['ID_default2'].verification_criteria_french).to eq('')

        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/vc_lang/not_specified.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_not'].respond_to?('verification_criteria_german')).to be(true)
        expect(loader.requirements['ID_not'].respond_to?('verification_criteria_english')).to be(false)
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/vc_lang/no_string.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_language'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"verification_criteria_german\" must be String not Array"
        end
      end
    end

    context 'language variants of comment' do
      it 'shall be any string', doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/comment_lang/valid.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ESR_Test_1'].comment).to eq("juhu\njuhu")
        expect(loader.requirements['ESR_Test_1'].comment_spanish).to eq('ole')
        expect(loader.requirements['ESR_Test_2'].comment).to eq('mist')
        expect(loader.requirements['ESR_Test_2'].comment_english).to eq('damn')
        expect(loader.requirements['ESR_Test_3'].comment).to eq('achso')
        expect(loader.requirements['ESR_Test_3'].comment_french).to eq('')
      end

      it 'shall be an empty string if not specified in this particular requirement but specified in another requirement',
         doc_refs: ['Dim_ReqFiles_language'] do
        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/comment_lang/default.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_default1'].comment_german).to eq('')
        expect(loader.requirements['ID_default1'].comment_french).to eq('bla')
        expect(loader.requirements['ID_default2'].comment_german).to eq('')
        expect(loader.requirements['ID_default2'].comment_french).to eq('')

        loader = Dim::Loader.new
        loader.load(file: "#{TEST_INPUT_DIR}/reqs/comment_lang/not_specified.dim")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(loader.requirements['ID_not'].respond_to?('comment_german')).to be(true)
        expect(loader.requirements['ID_not'].respond_to?('comment_english')).to be(false)
      end

      context 'when value is no string' do
        let(:filename) { "#{TEST_INPUT_DIR}/reqs/comment_lang/no_string.dim" }

        it 'shall throw an error and print a meaningful error message',
          doc_refs: ['Dim_ReqFiles_language'] do
          Test.main("check -i #{filename}")
          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include "Error: in #{filename}: value of attribute \"comment_german\" must be String not Array"
        end
      end
    end
  end
end
# rubocop:enable Metric/BlockLength, Layout/LineLength
