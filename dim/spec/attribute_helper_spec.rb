require 'framework/helper'

RSpec.describe 'Dim::Helpers::AttributeHelper' do
  let(:dummy_class) { Class.new { include Dim::Helpers::AttributeHelper }.new }

  describe '#change_type_to_format_style' do
    subject { dummy_class.change_type_to_format_style(config) }

    context "when 'type' is given in the config" do
      let(:config) { { type: 'single' } }

      it "replaces 'type' key in the config with the 'format_style' with value",
         doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(subject).to eq('single')
        expect(config[:format_style]).to eq('single')
        expect(config[:type]).to be nil
        expect(config.keys).to eq([:format_style])
      end
    end

    context "when 'type' is not given" do
      let(:config) { { format_shift: 0 } }

      it "returns nil and changes 'type' key to 'format_style'", doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(subject).to be nil
        expect(config[:format_style]).to be nil
        expect(config[:type]).to be nil
        expect(config.keys).to match_array(%i[format_shift format_style])
      end
    end
  end

  describe '#check_for_default_attributes' do
    let(:filename) { 'attributes.dim' }

    context 'when attributes.dim does not redefine default attributes' do
      let(:attributes) { { 'cluster' => { format_style: :text, default: '', format_shift: 0 } } }

      it 'returns nil without returning nil', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(dummy_class.check_for_default_attributes(attributes, filename)).to be nil
      end
    end

    context 'when attributes.dim redefines the default attributes' do
      let(:attributes) { { 'type' => { format_style: :text, default: '', format_shift: 0 } } }
      let(:err_msg) { 'Error: Defining standard attributes as a custom attributes is not allowed' }

      it 'exits process with error message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        Dim::Test.execute { dummy_class.check_for_default_attributes(attributes, filename) }

        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include(err_msg)
      end
    end
  end

  describe '#validate_format_style' do
    context "when format_style in the config is 'list', 'multi', 'single', 'split' or 'text" do
      let(:config) { { format_style: %w[list multi single split text].sample } }

      it 'returns nil without any error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(dummy_class.validate_format_style('custom_attribute', config)).to be nil
      end
    end

    context 'when format_style is other than valid attribute' do
      let(:config) { { format_style: [1, 0.5, nil, true, 'singular', 'multiple'].sample } }

      it 'exits with the error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        Dim::Test.execute { dummy_class.validate_format_style('custom_attribute', config) }

        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include('Error: Invalid')
      end
    end
  end

  describe '#add_check_value' do
    subject { dummy_class.add_check_value(config) }

    context "when 'format_style' is 'single'" do
      let(:config) { { format_style: 'single' } }

      it 'adds check in the config', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        subject
        expect(config[:check]).to eq :check_single_enum
      end
    end

    context "when 'format_style' if 'multi'" do
      let(:config) { { format_style: 'multi' } }

      it 'adds check in the config', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        subject
        expect(config[:check]).to eq :check_multi_enum
      end
    end

    context "when 'format_style' is other than 'single' or 'multi'" do
      let(:config) { { format_style: %w[list text split].sample } }

      it 'does not set check in the config', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        subject
        expect(config[:check]).to be nil
      end
    end
  end

  describe '#validate_default' do
    context "when default value is not set to 'auto'" do
      let(:config) { { default: ['', 'new'].sample } }

      it 'returns nil without raising an exception', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(dummy_class.validate_default('default', config)).to be nil
      end
    end

    context "when default value is set to 'auto'" do
      let(:config) { { default: 'auto' } }

      it 'exits process with error message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        Dim::Test.execute { dummy_class.validate_default('default', config) }

        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include('Error: Invalid')
      end
    end
  end

  describe '#validate_default_for_enum' do
    subject { dummy_class.validate_default_for_enum('default', config) }

    context "when 'format-_style' is not 'single' or 'multi'" do
      let(:config) { { format_style: %w[text list split].sample } }

      it 'returns nil', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(subject).to be nil
      end
    end

    context "when 'format_style' is 'single' or 'multi'" do
      let(:config) { { format_style: %w[single multi].sample, allowed: %w[green blue red yellow] } }

      context "when default value is present in list of 'allowed' values provided" do
        before { config[:default] = 'green' }

        it 'returns nil without raising any error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(subject).to be nil
        end
      end

      context "when default value is not present in the list of 'allowed' values provided" do
        before { config[:default] = 'black' }

        it 'exits process with a meaningful message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          Dim::Test.execute { dummy_class.validate_default_for_enum('default', config) }

          expect(Dim::ExitHelper.exit_code).to eq 1
          expect(@test_stderr).to include('Error: default value for default must be from allowed list')
        end
      end
    end
  end

  describe '#validate_allowed' do
    context "when allowed is set to 'nil' or an array" do
      let(:config) { { allowed: [nil, [1, 2]].sample } }

      it 'returns nil without raising an error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(dummy_class.validate_allowed('custom_attribute', config)).to be nil
      end
    end

    context "when allowed value is other than 'nil' or array" do
      let(:config) { { allowed: [1, 2, 'test'].sample } }

      it 'exits with raising error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        Dim::Test.execute { dummy_class.validate_allowed('custom_attribute', config) }

        expect(Dim::ExitHelper.exit_code).to be 1
        expect(@test_stderr).to include('Error: Invalid')
      end
    end
  end

  describe '#validate_allowed_for_enum' do
    context 'when attribute is not of enum type' do
      let(:config) { { format_style: %w[singular multiple].sample } }

      it 'returns nil without raising an error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
        expect(dummy_class.validate_allowed_for_enum('custom_attribute', config)).to be nil
      end
    end

    context 'when attribute is of enum type' do
      let(:config) { { format_style: %w[single multi].sample } }

      context 'when array of string values is given as a allowed values' do
        before { config[:allowed] = %w[true random] }

        it 'returns nil without raising an error', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(dummy_class.validate_allowed_for_enum('custom_attribute', config)).to be nil
        end
      end

      context 'when array is not give for allowed attributes' do
        before { config[:allowed] = 'dummy_string' }

        it 'exits process with error message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          Dim::Test.execute { dummy_class.validate_allowed_for_enum('custom_attribute', config) }

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include('Error: Allowed value must be list of strings')
        end
      end

      context 'when array contains non string value' do
        before { config[:allowed] = [true, 'false'] }

        it 'exits process with error message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          Dim::Test.execute { dummy_class.validate_allowed_for_enum('custom_attribute', config) }

          expect(Dim::ExitHelper.exit_code).to be 1
          expect(@test_stderr).to include('Error: Allowed value must be list of strings')
        end
      end
    end
  end

  describe '#symbolize_values' do
    before(:each) { dummy_class.symbolize_values(config) }

    context 'changes format_style to symbol from string' do
      context 'when format_style is present' do
        let(:config) { { format_style: 'single' } }

        it 'converts string value to symbol', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(config[:format_style]).to eq :single
        end
      end

      context 'when format_style in missing' do
        let(:config) { {} }

        it 'does not update the format_style', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(config[:format_style]).to be nil
        end
      end
    end

    context 'changes format_shift from string to integer' do
      context 'when format_shift is given by user' do
        let(:config) { { format_shift: '10' } }

        it 'converts string to integer value', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(config[:format_shift]).to eq 10
        end
      end

      context 'when format_shift is not given by user' do
        let(:config) { {} }

        it 'sets default format_shift to 0', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
          expect(config[:format_shift]).to eq 0
        end
      end
    end
  end

  describe '#exit_with_error' do
    let(:config) { 'check' }
    let(:config_value) { 'invalid_value' }
    let(:attribute) { 'custom_attribute' }

    it 'exits the process with error message', doc_refs: ['Dim_AttributeLoading_UnitTests'] do
      Dim::Test.execute do
        dummy_class.send(
          :exit_with_error,
          **{ config: config, config_value: config_value, attribute: attribute }
        )
      end

      expect(Dim::ExitHelper.exit_code).to be 1
      expect(@test_stderr).to include("Error: Invalid value \"#{config_value}\" for #{config} detected for attribute #{attribute}")
    end
  end
end
