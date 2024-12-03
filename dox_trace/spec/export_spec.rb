require_relative 'framework/helper'

module Sphinx
  describe "The export to Dim format" do
    context 'with a valid dox_trace_dim_root configuration' do
      before do
        FileUtils.mkdir_p("spec/test_input/export/export_root/srs")
        FileUtils.mkdir_p("spec/test_input/export/export_root/swa")
        FileUtils.mkdir_p("spec/test_input/export/export_root/smd/dummy")
        FileUtils.touch("spec/test_input/export/export_root/srs/dummy.dim")
        FileUtils.touch("spec/test_input/export/export_root/swa/dummy.dim")
        FileUtils.touch("spec/test_input/export/export_root/smd/dummy/dummy.dim")
        @test = Test.new("export")
        @test.run
      end

      it 'shall contain srs, spec, unit, interface, mod with their IDs', doc_refs: ['DoxTrace_Export_Config', 'DoxTrace_Export_IDs'] do
        expect(@test.exit_code).to be == 0
        srs = @test.dim_original_data["spec/test_input/export/export_root/srs/index.dim"]
        expect(srs.include?"SRS_Srs_Type").to be true
        expect(srs.include?"SRS_Requirement_Type").to be false
        expect(srs.include?"SRS_Information_Type").to be false
        expect(srs.include?"InputRequirement_Type").to be false
        expect(srs.include?"InputInformation_Type").to be false
        expect(srs.include?"SWA_Spec_Type").to be false
        expect(srs.include?"SWA_Interface_Type").to be false
        expect(srs.include?"SWA_Mod_Type").to be false
        expect(srs.include?"SMD_Unit_Type").to be false

        swa = @test.dim_original_data["spec/test_input/export/export_root/swa/index.dim"]
        expect(swa.include?"SRS_Srs_Type").to be false
        expect(swa.include?"SRS_Requirement_Type").to be false
        expect(swa.include?"SRS_Information_Type").to be false
        expect(swa.include?"InputRequirement_Type").to be false
        expect(swa.include?"InputInformation_Type").to be false
        expect(swa.include?"SWA_Spec_Type").to be true
        expect(swa.include?"SWA_Interface_Type").to be true
        expect(swa.include?"SWA_Mod_Type").to be true
        expect(swa.include?"SMD_Unit_Type").to be false

        smd = @test.dim_original_data["spec/test_input/export/export_root/smd/index.dim"]
        expect(smd.include?"SRS_Srs_Type").to be false
        expect(smd.include?"SRS_Requirement_Type").to be false
        expect(smd.include?"SRS_Information_Type").to be false
        expect(smd.include?"InputRequirement_Type").to be false
        expect(smd.include?"InputInformation_Type").to be false
        expect(smd.include?"SMD_Unit_Type").to be true
        expect(smd.include?"SWA_Spec_Type").to be false
        expect(smd.include?"SWA_Interface_Type").to be false
        expect(smd.include?"SWA_Mod_Type").to be false
      end

      it 'shall create the same folder and filename structure as the according RST files',
        doc_refs: ['DoxTrace_Export_Filenames'] do
        data = @test.dim_original_data

        expect(data.include?"spec/test_input/export/export_root/srs/index.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/srs/subfolder/b.dim").to be false
        expect(data.include?"spec/test_input/export/export_root/srs/subfolder/a.dim").to be false
        expect(data.include?"spec/test_input/export/export_root/srs/subfolder/b/c.dim").to be false
        expect(data.include?"spec/test_input/export/export_root/srs/subfolder/b/d.dim").to be false

        expect(data.include?"spec/test_input/export/export_root/swa/index.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/swa/subfolder/a.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/swa/subfolder/b.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/swa/subfolder/b/c.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/swa/subfolder/b/d.dim").to be false

        expect(data.include?"spec/test_input/export/export_root/smd/index.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/smd/subfolder/b.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/smd/subfolder/a.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/smd/subfolder/b/c.dim").to be true
        expect(data.include?"spec/test_input/export/export_root/smd/subfolder/b/d.dim").to be false
      end

      it 'shall cleanup the output folder before writing the RST files for srs, swa and smd',
        doc_refs: ['DoxTrace_Export_Delete'] do

        expect(File.exist?("spec/test_input/export/export_root/srs/dummy.dim")).to be false
        expect(File.exist?("spec/test_input/export/export_root/swa/dummy.dim")).to be false
        expect(File.exist?("spec/test_input/export/export_root/smd/dummy/dummy.dim")).to be false
        FileUtils.rm_f("spec/test_input/export/export_root/srs/dummy.dim")
        FileUtils.rm_f("spec/test_input/export/export_root/swa/dummy.dim")
        FileUtils.rm_rf("spec/test_input/export/export_root/smd/dummy")
      end

      it 'shall include the correct module names', doc_refs: ['DoxTrace_Export_ModuleName'] do
        data = @test.dim_original_data

        expect(data["spec/test_input/export/export_root/swa/index.dim"]["document"]).to eq "SWA_Spec"
        expect(data["spec/test_input/export/export_root/swa/subfolder/b.dim"]["document"]).to eq "SWA_ModB"
        expect(data["spec/test_input/export/export_root/smd/subfolder/a.dim"]["document"]).to eq "SMD_ModA"
        expect(data["spec/test_input/export/export_root/smd/subfolder/b/c.dim"]["document"]).to eq "SMD_ModC"

        expect(data["spec/test_input/export/export_root/swa/subfolder/b.dim"]).to have_key("SWA_ModB_2")
        expect(data["spec/test_input/export/export_root/smd/subfolder/b.dim"]).to have_key("SMD_ModB_1")
        expect(data["spec/test_input/export/export_root/swa/subfolder/a.dim"]).to have_key("SWA_ModA_2")
        expect(data["spec/test_input/export/export_root/smd/subfolder/a.dim"]).to have_key("SMD_ModA_1")
        expect(data["spec/test_input/export/export_root/swa/subfolder/b/c.dim"]).to have_key("SWA_ModC_2")
        expect(data["spec/test_input/export/export_root/smd/subfolder/b/c.dim"]).to have_key("SMD_ModC_1")
      end
    end

    context 'with only swa and smd' do
      before do
        FileUtils.mkdir_p("spec/test_input/export_no_srs/export_root/srs")
        FileUtils.mkdir_p("spec/test_input/export_no_srs/export_root/swa")
        FileUtils.mkdir_p("spec/test_input/export_no_srs/export_root/smd/dummy")
        FileUtils.touch("spec/test_input/export_no_srs/export_root/srs/dummy.dim")
        FileUtils.touch("spec/test_input/export_no_srs/export_root/swa/dummy.dim")
        FileUtils.touch("spec/test_input/export_no_srs/export_root/smd/dummy/dummy.dim")
        @test = Test.new("export_no_srs")
        @test.run
      end

      it 'shall cleanup the output folder before writing the RST files for swa and smd, but not srs',
        doc_refs: ['DoxTrace_Export_Delete'] do

        expect(File.exist?("spec/test_input/export_no_srs/export_root/srs/dummy.dim")).to be true
        expect(File.exist?("spec/test_input/export_no_srs/export_root/swa/dummy.dim")).to be false
        expect(File.exist?("spec/test_input/export_no_srs/export_root/smd/dummy/dummy.dim")).to be false
        FileUtils.rm_rf("spec/test_input/export_no_srs/export_root/srs")
        FileUtils.rm_f("spec/test_input/export_no_srs/export_root/swa/dummy.dim")
        FileUtils.rm_rf("spec/test_input/export_no_srs/export_root/smd/dummy")
      end
    end

    context 'without a valid dox_trace_dim_root configuration' do
      before do
        @test = Test.new("export_no_config")
        @test.run
      end

      it 'shall be skipped and not error returned', doc_refs: ['DoxTrace_Export_Config'] do
        expect(@test.exit_code).to be == 0
        expect(File.exist?("#{$test_input_dir}/export_no_config/export_root")).to be false
        expect(@test.test_stderr).not_to include 'writing Dim files'
      end
    end

    context 'with an invalid dox_trace_dim_root configuration' do
      before do
        @test = Test.new("export_invalid_config")
        @test.run
      end

      it 'shall cause dox_trace to abort with exit code != 0 and print an error message', doc_refs: ['DoxTrace_Export_Config'] do
        expect(@test.exit_code).to be > 0
        expect(File.exist?("#{$test_input_dir}/export_invalid_config/export_root")).to be false
        expect(@test.test_stderr).not_to include 'writing Dim files'
        expect(@test.test_stderr).to include 'exception'
      end
    end
  end
end
