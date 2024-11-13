require_relative '../exit_helper'

module Dim
  module Refinements
    refine Psych::Nodes::Document do
      def line_numbers
        hash = {}
        children[0].children.each do |node|
          hash[node.value] = node.start_line + 1 if node.is_a?(Psych::Nodes::Scalar)
        end
        hash
      end
    end
  end
end

module Psych
  module Visitors
    class ToRuby
      alias revive_hash_org revive_hash

      def patched_revive_hash(hash, o)
        test_hash = {}
        o.children.each_slice(2) do |k, _v|
          key = accept(k)
          if test_hash.key?(key)
            line = "line #{k.start_line + 1}: "
            Dim::ExitHelper.exit(code: 1, msg: "#{line}found \"#{key}\" twice which must be unique.")
          end
          test_hash[key] = k
        end
        revive_hash_org hash, o
      end

      def self.add_patch
        alias_method :revive_hash, :patched_revive_hash
      end

      def self.revert_patch
        alias_method :revive_hash, :revive_hash_org
      end
    end
  end

  module Nodes
    class Scalar
      alias initialize_org initialize
      def quoted_initialize(value, anchor = nil, tag = nil, plain = true, _quoted = false, style = ANY)
        initialize_org(value, anchor, tag, plain, true, style)
      end

      def self.add_patch
        alias_method :initialize, :quoted_initialize
      end

      def self.revert_patch
        alias_method :initialize, :initialize_org
      end
    end
  end
end
