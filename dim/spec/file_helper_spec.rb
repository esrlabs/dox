require_relative 'framework/helper'

class Dummy
  include Dim::Helpers::FileHelper
end

module Dim
  describe 'File helper methods' do
    it 'shall print error message when empty file is loaded', doc_refs: ['Dim_loading_readBad'] do
      begin
        $test_exception = nil
        Dummy.new.open_yml_file('./spec/test_input/invalid_input/', 'empty_yaml.dim')
      rescue Exception => e
        $test_exception = e
      end
      expect(@test_stderr).to include 'not a valid yaml file'
    end
  end
end
