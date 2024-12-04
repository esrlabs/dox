require_relative 'framework/helper'

module Sphinx
  describe "The attribute verification_methods" do
    context 'with correct syntax' do
      before(:all) do
        @test = Test.new("verification_methods")
        @test.run
      end

      it 'shall be loaded and displayed correctly without any error', doc_refs: ['DoxTrace_Syntax_VerificationMethods', 'DoxTrace_HTML_VerificationMethods'] do
        expect(@test.exit_code).to be == 0
        data = HtmlData.new("verification_methods", "index.html")

        expect(data.value("SRS_Requirement_VerificationMethodsSet", "verification_methods")).to eq 'on_target, off_target'
        expect(data.value("InputRequirement_VerificationMethodsSet", "verification_methods")).to eq 'manual'
        expect(data.value("SRS_Srs_VerificationMethodsSet", "verification_methods")).to eq 'on_target, off_target'
        expect(data.value("SWA_Spec_VerificationMethodsSet", "verification_methods")).to eq 'off_target, on_target'
        expect(data.value("SMD_Unit_VerificationMethodsSet", "verification_methods")).to eq 'none'
        expect(data.value("SWA_Interface_VerificationMethodsSet", "verification_methods")).to eq 'off_target'
        expect(data.exist?("SMD_Interface_VerificationMethodsSet", "verification_methods")).to be false

        expect(data.value("SRS_Requirement_VerificationMethodsDefault", "verification_methods")).to eq '-'
        expect(data.value("InputRequirement_VerificationMethodsDefault", "verification_methods")).to eq '-'
        expect(data.value("SRS_Srs_VerificationMethodsDefault", "verification_methods")).to eq 'on_target'
        expect(data.value("SWA_Spec_VerificationMethodsDefault", "verification_methods")).to eq 'on_target'
        expect(data.value("SMD_Spec_VerificationMethodsDefault", "verification_methods")).to eq 'off_target'
        expect(data.value("SMD_Unit_VerificationMethodsDefault", "verification_methods")).to eq 'off_target'
        expect(data.value("SWA_Interface_VerificationMethodsDefault", "verification_methods")).to eq 'on_target'

        expect(data.exist?("SMD_Interface_VerificationMethodsDefault", "verification_methods")).to be false
        expect(data.exist?("SWA_Mod_VerificationMethodsDefault", "verification_methods")).to be false
      end

      it 'shall get the value from test_setups if verification_methods is not defined', doc_refs: ['DoxTrace_Syntax_TestSetupsToVerificationMethods', 'DoxTrace_HTML_VerificationMethods', 'DoxTrace_HTML_TestSetups'] do
        expect(@test.exit_code).to be == 0
        data = HtmlData.new("verification_methods", "index.html")

        expect(data.value("SWA_Spec_VerificationMethodsBackward", "verification_methods")).to eq 'off_target, on_target'
        expect(data.exist?("SWA_Spec_VerificationMethodsBackward", "test_setups")).to be false
        expect(data.value("SWA_Spec_VerificationMethodsBackwardBoth", "verification_methods")).to eq 'off_target, on_target, manual'
        expect(data.exist?("SWA_Spec_VerificationMethodsBackwardBoth", "test_setups")).to be false
      end

      it 'shall be exported correctly', doc_refs: ['DoxTrace_Syntax_VerificationMethods', 'DoxTrace_Export_Attributes', 'DoxTrace_Export_VerificationMethods', 'DoxTrace_Export_TestSetups'] do
        srs = @test.dim_original_data["spec/test_input/verification_methods/export_root/srs/index.dim"]
        expect(srs["SRS_Srs_VerificationMethodsSet"]["verification_methods"]).to eq 'on_target, off_target'
        expect(srs["SRS_Srs_VerificationMethodsDefault"]["verification_methods"]).to eq 'on_target'

        swa = @test.dim_original_data["spec/test_input/verification_methods/export_root/swa/index.dim"]
        expect(swa["SWA_Spec_VerificationMethodsSet"]["verification_methods"]).to eq 'off_target, on_target'
        expect(swa["SWA_Interface_VerificationMethodsSet"]["verification_methods"]).to eq 'off_target'
        expect(swa["SWA_Spec_VerificationMethodsDefault"]["verification_methods"]).to eq 'on_target'
        expect(swa["SWA_Interface_VerificationMethodsDefault"]["verification_methods"]).to eq 'on_target'

        expect(swa["SWA_Spec_VerificationMethodsBackward"]["verification_methods"]).to eq 'off_target, on_target'
        expect(swa["SWA_Spec_VerificationMethodsBackwardBoth"]["verification_methods"]).to eq 'off_target, on_target, manual'
        content = File.read("spec/test_input/verification_methods/export_root/swa/index.dim")
        expect(content).not_to include "test_setups"

        smd = @test.dim_original_data["spec/test_input/verification_methods/export_root/smd/index.dim"]
        expect(smd["SMD_Interface_VerificationMethodsSet"]["verification_methods"]).to eq 'none'
        expect(smd["SMD_Unit_VerificationMethodsSet"]["verification_methods"]).to eq 'none'
        expect(smd["SMD_Spec_VerificationMethodsDefault"]["verification_methods"]).to eq 'off_target'
        expect(smd["SMD_Unit_VerificationMethodsDefault"]["verification_methods"]).to eq 'off_target'
        expect(smd["SMD_Interface_VerificationMethodsDefault"]["verification_methods"]).to eq 'none'
      end
    end

    context 'specified in an interface directive' do
      before(:all) do
        @test = Test.new("verification_methods_information")
        @test.run
      end

      it 'shall cause dox_trace to abort with exit code != 0 and print an error message', doc_refs: ['DoxTrace_Syntax_VerificationMethods'] do
        expect(@test.exit_code).to be > 0
        expect(@test.test_stderr).to include 'index.rst:7:Error in "information" directive'
        expect(@test.test_stderr).to include 'unknown option: "verification_methods"'
      end
    end

    context 'specified in an information directive' do
      before(:all) do
        @test = Test.new("verification_methods_information")
        @test.run
      end

      it 'shall cause dox_trace to abort with exit code != 0 and print an error message', doc_refs: ['DoxTrace_Syntax_VerificationMethods'] do
        expect(@test.exit_code).to be > 0
        expect(@test.test_stderr).to include 'index.rst:7:Error in "information" directive'
        expect(@test.test_stderr).to include 'unknown option: "verification_methods"'
      end
    end

    context 'specified in an mod directive' do
      before(:all) do
        @test = Test.new("verification_methods_mod")
        @test.run
      end

      it 'shall cause dox_trace to abort with exit code != 0 and print an error message', doc_refs: ['DoxTrace_Syntax_VerificationMethods'] do
        expect(@test.exit_code).to be > 0
        expect(@test.test_stderr).to include 'index.rst:7:Error in "mod" directive'
        expect(@test.test_stderr).to include 'unknown option: "verification_methods"'
      end

    end
  end
end
