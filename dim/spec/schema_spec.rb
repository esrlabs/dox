require_relative 'framework/helper'

module Dim
  describe 'dim schema' do
    context 'with custom attributes' do
      it 'generates JSON schema along with custom properties', doc_refs: %w[Dim_schema_general] do
        Test.main("schema -i #{TEST_INPUT_DIR}/with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR}")
        expect(@test_stdout).to include "JSON schema saved at #{TEST_OUTPUT_DIR}"
        generated = File.read("#{TEST_OUTPUT_DIR}/dim_schema.json")
        expected = File.read("#{TEST_INPUT_DIR}/schemas/with_custom_attributes.json")

        expect(generated).to eq(expected)
      end
    end

    context 'without any custom attributes' do
      it 'generates the default Dim schema', doc_refs: %w[Dim_schema_general] do
        Test.main("schema -i #{TEST_INPUT_DIR}/format/inplace/complete.conf -o #{TEST_OUTPUT_DIR}/default")
        expect(@test_stdout).to include "JSON schema saved at #{TEST_OUTPUT_DIR}/default"

        generated = File.read("#{TEST_OUTPUT_DIR}/default/dim_schema.json")
        expected = File.read("#{TEST_INPUT_DIR}/schemas/without_custom_attributes.json")

        expect(generated).to eq(expected)
      end
    end

    context 'when logs are silented' do
      it 'does not print log messages', doc_refs: %w[Dim_schema_general] do
        Test.main("schema -i #{TEST_INPUT_DIR}/with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR}/silent --silent")

        expect(@test_stdout).not_to include "JSON schema saved at #{TEST_OUTPUT_DIR}"
      end
    end

    context 'when directory is present' do
      before { FileUtils.mkdir_p(TEST_OUTPUT_DIR) }

      it 'does not create a directory', doc_refs: %w[Dim_schema_general] do
        Test.main("schema -i #{TEST_INPUT_DIR}/with_custom_attributes/Config.dim -o #{TEST_OUTPUT_DIR}")
        expect(@test_stdout).to include "JSON schema saved at #{TEST_OUTPUT_DIR}"
      end
    end
  end
end
