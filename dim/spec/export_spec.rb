require_relative 'framework/helper'

module Dim
  describe 'dim export' do
    context 'in general' do
      it 'shall write correct (language) attributes in the file format specified by command line option',
         doc_refs: %w[Dim_export_general Dim_loading_readGood] do
        Test.main("export -i #{TEST_INPUT_DIR}/language/module_ok.dim -o #{TEST_OUTPUT_DIR} -f json")
        out_ref = File.read("#{TEST_INPUT_DIR}/language/output/Requirements.json").universal_newline
        out_is  = File.read("#{TEST_OUTPUT_DIR}/language/Requirements.json").universal_newline
        expect(out_is).to eq(out_ref)
      end

      it 'shall export to <outputFolder>/<document>/Requirements.<type>', doc_refs: ['Dim_export_documents'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR}/new_dir -f json")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(File.exist?("#{TEST_OUTPUT_DIR}/new_dir/test_module_1/Requirements.json")).to eq true
        expect(File.exist?("#{TEST_OUTPUT_DIR}/new_dir/test_module_2/Requirements.json")).to eq true
      end

      it 'shall merge a module which is split in several requirements files', doc_refs: ['Dim_export_documents'] do
        Test.main("export -i #{TEST_INPUT_DIR}/one_module_in_several_files/Config.yml -o #{TEST_OUTPUT_DIR} -f json")
        j = JSON.parse(File.read("#{TEST_OUTPUT_DIR}/TestModule/Requirements.json"))
        expect(j.length).to eq 2 # number of entries
        expect(j.select { |e| e['document_name'] == 'TestModule' }.length).to eq 2
        expect(Dim::ExitHelper.exit_code).to eq 0
      end

      it 'shall sanitize module names', doc_refs: ['Dim_export_documents'] do
        Test.main("export -i #{TEST_INPUT_DIR}/slash_in_modname/test_module_1.dim -o #{TEST_OUTPUT_DIR} -f json --allow-missing")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(File.exist?("#{TEST_OUTPUT_DIR}/test_module/Requirements.json")).to eq true
      end

      it 'shall copy enclosed files to the output folder', doc_refs: ['Dim_export_enclosed'] do
        Test.main("export -i #{TEST_INPUT_DIR}/enclosed_check/test_module_1_1.dim -o #{TEST_OUTPUT_DIR} -f json")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(File.exist?("#{TEST_OUTPUT_DIR}/test_module/test.txt")).to eq true
      end

      it 'shall only export items which match the filter if a filter is given by command line options',
         doc_refs: ['Dim_export_filter'] do
        Test.main("export -i #{TEST_INPUT_DIR}/filter_check/module.dim --filter \"type == requirement && text =~ /test/\ && category != software\" -o #{TEST_OUTPUT_DIR} -f rst")
        h = File.read("#{TEST_OUTPUT_DIR}/test/Requirements.rst")
        expect(h).not_to include('test_id_1')
        expect(h).to include('test_id_2')
        expect(h).not_to include('test_id_3')
        expect(h).to include('test_id_4')
      end

      it 'shall print info message when silent option is set to false', doc_refs: ['Dim_export_general'] do
        Test.main("export -i #{TEST_INPUT_DIR}/language/module_ok.dim -o #{TEST_OUTPUT_DIR} -f json --silent")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).not_to include 'Exporting...'
        expect(@test_stdout).not_to include 'Done.'
      end
    end

    context 'shall throw an error and print a meaningful error message' do
      it 'if specified without input files', doc_refs: ['Dim_export_general'] do
        Test.main('export')
        expect(Dim::ExitHelper.exit_code).to be > 0
        expect(@test_stderr).to include 'no input file specified.'
      end

      it 'if specified without output folder', doc_refs: ['Dim_export_general'] do
        Test.main("export -i #{TEST_INPUT_DIR}/one_module_in_several_files/Config.yml")
        expect(@test_stderr).to include('specify output folder')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end

      it 'if specified with invalid file format', doc_refs: %w[Dim_export_general Dim_CLI_exit] do
        Test.main("export -i #{TEST_INPUT_DIR}/one_module_in_several_files/Config.yml -o #{TEST_OUTPUT_DIR}/wrong -f wrong")
        expect(File.exist?("#{TEST_OUTPUT_DIR}/wrong.txt")).to eq false
        expect(@test_stderr).to include('export format must be one of: rst, csv, json')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end

      it 'if specified without file format', doc_refs: %w[Dim_export_general Dim_CLI_exit] do
        Test.main("export -i #{TEST_INPUT_DIR}/one_module_in_several_files/Config.yml -o #{TEST_OUTPUT_DIR}/wrong")
        expect(File.exist?("#{TEST_OUTPUT_DIR}/wrong.txt")).to eq false
        expect(@test_stderr).to include('export format not specified, must be one of: rst, csv, json')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'to JSON' do
      it 'shall include attributes as key/values pairs plus  ID, module name and originator',
         doc_refs: ['Dim_export_json'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR}/new_dir -f json")
        expect(Dim::ExitHelper.exit_code).to eq 0
        j = JSON.parse(File.read("#{TEST_OUTPUT_DIR}/new_dir/test_module_1/Requirements.json"))
        expect(j.find { |e| e['id'] == 'test_id_1' } ['text']).to eq 'Another test req'
        expect(j.find { |e| e['id'] == 'test_id_1' } ['document_name']).to eq 'test_module_1'
        expect(j.find { |e| e['id'] == 'test_id_1' } ['originator']).to eq 'CompanyName'
        expect(Dim::ExitHelper.exit_code).to eq 0
      end
    end

    context 'to CSV' do
      it 'shall print "Sep=", into the first line', doc_refs: ['Dim_export_csvSep'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_calculated_infos/Input1.yml -o #{TEST_OUTPUT_DIR} -f csv")
        csv_content = File.readlines("#{TEST_OUTPUT_DIR}/ABC123/Requirements.csv")
        expect(csv_content[0].strip).to eq('Sep=,')
      end
      it 'shall print all attributes, id, module name, originator',
         doc_refs: ['Dim_export_csvAttributes'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_calculated_infos/Input1.yml -o #{TEST_OUTPUT_DIR} -f csv")
        exported = File.read("#{TEST_OUTPUT_DIR}/ABC123/Requirements.csv")
        expected = File.read("#{TEST_INPUT_DIR}/export_calculated_infos/output/Requirements1.csv")
        expect(exported).to eq(expected)
      end
      it 'shall double quote strings and escape existing double quotes', doc_refs: ['Dim_export_csvValues'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_calculated_infos/Input2.yml -o #{TEST_OUTPUT_DIR} -f csv")
        exported = File.read("#{TEST_OUTPUT_DIR}/ABC123/Requirements.csv")
        expected = File.read("#{TEST_INPUT_DIR}/export_calculated_infos/output/Requirements2.csv")
        expect(exported).to eq(expected)
      end
    end

    context 'to RST' do
      it 'shall write correct Sphinx syntax including index files',
         doc_refs: %w[Dim_export_rst Dim_export_rstIndex] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR} -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        # noinspection RubyLiteralArrayInspection
        ['index_001_software_companyname',
         'index_002_module_companyname',
         'index_003_module_xy_company',
         'mod01/Requirements',
         'mod02/Requirements',
         'mod03/Requirements',
         'mod04/Requirements',
         'mod05/Requirements',
         'mod06/Requirements',
         'mod07/Requirements',
         'mod08/Requirements',
         'mod09/Requirements',
         'mod10/Requirements',
         'mod11/Requirements',
         'test_module_1/Requirements',
         'test_module_2/Requirements',
         'test_module_3/Requirements',
         'test_module_4/Requirements',
         'test_module_5/Requirements',
         'X-_.test___srs_/Requirements'].each do |f|
          out_ref = File.read("#{TEST_INPUT_DIR}/export_check/output/#{f}.rst").universal_newline
          out_is  = File.read("#{TEST_OUTPUT_DIR}/#{f}.rst").universal_newline
          expect(out_is).to eq(out_ref)
        end
        expect(File.exist?("#{TEST_OUTPUT_DIR}/test_module_2/images/test.jpeg")).to eq true
      end

      it 'shall only write to file system if data has been changed', doc_refs: ['Dim_export_rstChange'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR} -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).to include 'Creating spec/test_output/mod09/Requirements.rst... done'
        expect(@test_stdout).to include 'Creating spec/test_output/mod10/Requirements.rst... done'
        expect(@test_stdout).to include 'Copying spec/test_input/export_check/images/test.jpeg to spec/test_output/test_module_2/images/test.jpeg...'

        @test_stdout.clear

        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR} -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).to include 'Creating spec/test_output/mod09/Requirements.rst... skipped'
        expect(@test_stdout).to include 'Creating spec/test_output/mod10/Requirements.rst... skipped'
        expect(@test_stdout).not_to include 'Copying spec/test_input/export_check/images/test.jpeg to spec/test_output/test_module_2/images/test.jpeg...'
      end

      it 'shall only write to file system if data has been changed without logs when silent option given',
         doc_refs: ['Dim_export_rstChange'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR} -f rst -s")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).not_to include 'Creating spec/test_output/mod09/Requirements.rst... done'
        expect(@test_stdout).not_to include 'Creating spec/test_output/mod10/Requirements.rst... done'
        expect(@test_stdout).not_to include 'Copying spec/test_input/export_check/images/test.jpeg to spec/test_output/test_module_2/images/test.jpeg...'

        Test.main("export -i #{TEST_INPUT_DIR}/export_check/Config.dim -o #{TEST_OUTPUT_DIR} -f rst")
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stdout).not_to include 'Creating spec/test_output/mod09/Requirements.rst... skipped'
        expect(@test_stdout).not_to include 'Creating spec/test_output/mod10/Requirements.rst... skipped'
        expect(@test_stdout).not_to include 'Copying spec/test_input/export_check/images/test.jpeg to spec/test_output/test_module_2/images/test.jpeg...'
      end

      it 'shall be possible with unresolved references when --allow-missing is specified',
         doc_refs: ['Dim_export_rst'] do
        Test.main("export -i #{TEST_INPUT_DIR}/missing_refs/test_module_1.dim -o #{TEST_OUTPUT_DIR} -f rst --allow-missing")
        expect(Dim::ExitHelper.exit_code).to eq 0
        h = File.read("#{TEST_OUTPUT_DIR}/test_module_1/Requirements.rst")
        expect(h).to include(':refs: non_exist')
      end

      it 'shall converted multiple spaces into correct Sphinx syntax', doc_refs: ['Dim_export_rst'] do
        Test.main("export -i #{TEST_INPUT_DIR}/spaces_html/module.dim -o #{TEST_OUTPUT_DIR} -f rst")
        out_ref = File.read("#{TEST_INPUT_DIR}/spaces_html/output/Requirements.rst").universal_newline
        out_is  = File.read("#{TEST_OUTPUT_DIR}/spaces_html/Requirements.rst").universal_newline
        expect(out_is).to eq(out_ref)
      end

      it 'shall write (nested) html strings correctly', doc_refs: ['Dim_export_rstStrings'] do
        Test.main("export -i #{TEST_INPUT_DIR}/nested_html/module.dim -o #{TEST_OUTPUT_DIR} -f rst")
        out_ref = File.read("#{TEST_INPUT_DIR}/nested_html/output/Requirements.rst").universal_newline
        out_is  = File.read("#{TEST_OUTPUT_DIR}/nested_html/Requirements.rst").universal_newline
        expect(out_is).to eq(out_ref)
      end
    end

    context 'to a specified folder' do
      it 'cleans up unused files from folder', doc_refs: ['Dim_export_cleanup'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/export_test_12_1.dim -o #{TEST_OUTPUT_DIR} -f csv")
        expect(Dir.new(File.join(TEST_OUTPUT_DIR,
                                 'test_export_12')).children).to match_array %w[images Requirements.csv]
        expect(Dir.new(File.join(TEST_OUTPUT_DIR, 'test_export_12', 'images')).children).to eq ['test.jpeg']

        Test.main("export -i #{TEST_INPUT_DIR}/export_check/export_test_12_2.dim -o #{TEST_OUTPUT_DIR} -f csv")
        expect(Dir.new(File.join(TEST_OUTPUT_DIR, 'test_export_12', 'images')).children).to eq ['test_new.jpeg']
      end

      it 'cleans folder for older files when originator changes in Config.dim', doc_refs: ['Dim_export_cleanup'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/using_config/Config.dim -o #{TEST_OUTPUT_DIR} -f csv")
        expect(Dir.new(File.join(TEST_OUTPUT_DIR)).children).to match_array(%w[test_module_1 test_module_2])
        Test.main("export -i #{TEST_INPUT_DIR}/export_check/using_config/SingleOriginConfig.dim -o #{TEST_OUTPUT_DIR} -f csv")
        expect(Dir.new(File.join(TEST_OUTPUT_DIR)).children).to match_array(['test_module_1'])
      end
    end

    context 'when custom attributes are provided by config file' do
      context 'to JSON' do
        it 'shall include attributes as key/values pairs plus  ID, module name and originator',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_export_json] do
          Test.main(
            "export -i #{TEST_INPUT_DIR}/export_with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR} -f json"
          )
          expect(Dim::ExitHelper.exit_code).to eq 0
          expected = JSON.parse(File.read("#{TEST_INPUT_DIR}/export_with_custom_attributes/output/Requirements.json"))
          actual = JSON.parse(File.read("#{TEST_OUTPUT_DIR}/test_module/Requirements.json"))

          expect(expected.to_json).to eq(actual.to_json)
        end
      end

      context 'to RST' do
        it 'should add custom attributes to exported data if attribute is not empty',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_export_rst] do
          Test.main("export -i #{TEST_INPUT_DIR}/export_with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR} -f rst")

          expect(Dim::ExitHelper.exit_code).to eq 0
          expected_op = File.read("#{TEST_INPUT_DIR}/export_with_custom_attributes/output/Requirements.rst").universal_newline
          actual_op = File.read("#{TEST_OUTPUT_DIR}/test_module/Requirements.rst").universal_newline

          expect(actual_op).to eq expected_op
        end
      end

      context 'to CSV' do
        it 'should add custom attributes to exported data if attribute is not empty',
           doc_refs: %w[Dim_ConfigFiles_Attribute Dim_AttrFiles_Attribute Dim_export_csvAttributes] do
          Test.main("export -i #{TEST_INPUT_DIR}/export_with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR} -f csv")
          expect(Dim::ExitHelper.exit_code).to be 0

          expected = File.read("#{TEST_INPUT_DIR}/export_with_custom_attributes/output/Requirements.csv")
          actual = File.read("#{TEST_OUTPUT_DIR}/test_module/Requirements.csv")

          expect(actual).to eq expected
        end
      end
    end

    context 'verification_methods' do
      context 'to json' do
        it 'shall not add test_setups in exported format', doc_refs: ['Dim_export_verificationMethods'] do
          Test.main("export -i #{TEST_INPUT_DIR}/verification_methods/verification_methods.dim -o #{TEST_OUTPUT_DIR} -f json")
          expected = File.read("#{TEST_INPUT_DIR}/verification_methods/output/verification_methods/Requirements.json")
          actual = File.read("#{TEST_OUTPUT_DIR}/verification_method_test/Requirements.json")
          expect(actual).to eq expected
        end
      end

      context 'to RST' do
        it 'shall not add test_setups in exported output', doc_refs: ['Dim_export_verificationMethods'] do
          Test.main("export -i #{TEST_INPUT_DIR}/verification_methods/verification_methods.dim -o #{TEST_OUTPUT_DIR} -f rst")
          expected = File.read("#{TEST_INPUT_DIR}/verification_methods/output/verification_methods/Requirements.rst").universal_newline
          actual = File.read("#{TEST_OUTPUT_DIR}/verification_method_test/Requirements.rst").universal_newline
          expect(actual).to eq expected
        end
      end

      context 'to csv' do
        it 'shall not add test_setups in exported output', doc_refs: ['Dim_export_verificationMethods'] do
          Test.main("export -i #{TEST_INPUT_DIR}/verification_methods/verification_methods.dim -o #{TEST_OUTPUT_DIR} -f csv")
          expected = File.read("#{TEST_INPUT_DIR}/verification_methods/output/verification_methods/Requirement.csv")
          actual = File.read("#{TEST_OUTPUT_DIR}/verification_method_test/Requirements.csv")
          expect(actual).to eq expected
        end
      end
    end

    context 'document' do
      context 'to json' do
        it 'shall replace module with document', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/modulename.dim -o #{TEST_OUTPUT_DIR} -f json")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/json/Requirements.json")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.json")

          expect(actual).to eq(expected)
        end

        it 'shall export document dim file', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/document.dim -o #{TEST_OUTPUT_DIR} -f json")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/json/Requirements.json")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.json")

          expect(actual).to eq(expected)
        end
      end

      context 'to csv' do
        it 'shall replace module with document', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/modulename.dim -o #{TEST_OUTPUT_DIR} -f csv")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/csv/Requirements.csv")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.csv")

          expect(actual).to eq(expected)
        end

        it 'shall export document dim file', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/document.dim -o #{TEST_OUTPUT_DIR} -f csv")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/csv/Requirements.csv")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.csv")

          expect(actual).to eq(expected)
        end
      end

      context 'to rst' do
        it 'shall replace module with document', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/modulename.dim -o #{TEST_OUTPUT_DIR} -f rst")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/rst/Requirements.rst")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.rst")

          expect(actual).to eq(expected)
        end

        it 'shall export document dim file', doc_refs: %w[Dim_loading_document Dim_export_general] do
          Test.main("export -i #{TEST_INPUT_DIR}/document/document.dim -o #{TEST_OUTPUT_DIR} -f rst")

          expected = File.read("#{TEST_INPUT_DIR}/document/output/rst/Requirements.rst")
          actual = File.read("#{TEST_OUTPUT_DIR}/ABC/Requirements.rst")

          expect(actual).to eq(expected)
        end
      end
    end

    context 'exporting an empty requirements' do
      it 'shall not raise an error', doc_refs: ['Dim_export_general'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_empty_requirements/module.dim -o #{TEST_OUTPUT_DIR} -f rst")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).not_to include 'Creating'
      end
    end

    context 'when file is already present in export folder' do
      before do
        FileUtils.mkdir_p('./spec/test_output/sample_export/export_test')
        FileUtils.cp(
          './spec/test_input/export_when_media_file_present/different_sample.txt',
          './spec/test_output/sample_export/export_test/sample.txt'
        )
      end

      after do
        FileUtils.remove_dir('./spec/test_output/sample_export')
      end

      it 'shall not copy the file', doc_refs: ['Dim_export_general'] do
        Test.main("export -i #{TEST_INPUT_DIR}/export_when_media_file_present/module.dim -o #{TEST_OUTPUT_DIR}/sample_export -f rst")
        expect(Dim::ExitHelper.exit_code).to be 0
        expect(@test_stdout).to include 'Copying'
      end
    end
  end
end
