require_relative 'framework/helper'

module Dim
  describe 'Command line option' do
    context '--help' do
      it ' shall show the usage information', doc_refs: ['Dim_CLI_help'] do
        Test.main('--help')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include('Usage: dim.rb')
      end
    end

    context '-h' do
      it ' shall show the usage information', doc_refs: ['Dim_CLI_help'] do
        Test.main('-h')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include('Usage: dim.rb')
      end
    end

    context '--version' do
      it ' shall show the current version', doc_refs: ['Dim_CLI_version'] do
        Test.main('--version')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include(Dim::Ver.sion)
      end
    end

    context '-v' do
      it ' shall show the current version', doc_refs: ['Dim_CLI_version'] do
        Test.main('-v')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include(Dim::Ver.sion)
      end
    end

    context '--license' do
      it ' shall show the current license', doc_refs: ['Dim_CLI_license'] do
        Test.main('--license')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include('Copyright')
      end
    end

    context '-l' do
      it ' shall show the current license', doc_refs: ['Dim_CLI_license'] do
        Test.main('-l')
        expect(Dim::ExitHelper.exit_code).to eq 0
        expect(@test_stderr).to include('Copyright')
      end
    end

    context 'with unknown argument' do
      it 'shall throw an error and print a meaningful error message', doc_refs: ['Dim_CLI_exit'] do
        Test.main("export -i #{TEST_INPUT_DIR}/one_module_in_several_files/Config.yml -o #{TEST_OUTPUT_DIR}/wrong --wrong-arg")
        expect(@test_stderr).to include('invalid option: --wrong-arg')
        expect(Dim::ExitHelper.exit_code).to be > 0
      end
    end

    context 'when empty argument is passed' do
      it 'shall throw an error and print error message', doc_ref: ['Dim_CLI_help'] do
        Test.main('')
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include('Usage: dim.rb <stats|check|export|format> [options]')
      end
    end

    context 'when invalid subcommand is passed' do
      it 'shall throw an error and print error message', doc_ref: ['Dim_CLI_exit'] do
        Test.main('wrong')
        expect(Dim::ExitHelper.exit_code).to eq 1
        expect(@test_stderr).to include('Usage: dim.rb <stats|check|export|format> [options]')
      end
    end
  end
end
