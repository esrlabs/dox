module Dim
  class ExitHelper
    @exit_code = 0

    class << self
      attr_reader :exit_code

      def reset_exit_code
        @exit_code = 0
      end

      def exit(msg:, code: 0, filename: nil)
        @exit_code = code
        inf = filename ? "in #{filename}: " : ''
        pre = code.positive? ? 'Error: ' : ''
        warn("#{pre}#{inf}#{msg}")
        Kernel.exit(code)
      end
    end
  end
end
