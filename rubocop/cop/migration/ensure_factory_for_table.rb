# frozen_string_literal: true

require_relative '../../code_reuse_helpers'

module RuboCop
  module Cop
    module Migration
      # Checks for `create_table` calls without a corresponding factory.
      #
      # This check is skipped when `ee/` directory is not present.
      #
      # @example
      #
      #   # bad
      #
      #   create_table :users do |t|
      #     t.string :name
      #     t.timestamps
      #   end
      #   # spec/factories/users.rb does not exist
      #
      # @example
      #
      #   # good
      #
      #   create_table :users do |t|
      #     t.string :name
      #     t.timestamps
      #   end
      #   # spec/factories/users.rb exists
      class EnsureFactoryForTable < RuboCop::Cop::Base
        include CodeReuseHelpers

        MSG = 'No factory found for the table `%{name}`.'

        RESTRICT_ON_SEND = %i[create_table].to_set.freeze

        def_node_matcher :table_definition, <<~PATTERN
          (send nil? RESTRICT_ON_SEND ${(sym $_) (str $_)} ...)
        PATTERN

        def on_send(node)
          # Migrations for EE models don't have factories in CE.
          return unless ee?

          table_definition(node) do |table_name_node, table_name|
            unless factory?(table_name.to_s)
              msg = format(MSG, name: table_name)
              add_offense(table_name_node, message: msg)
            end
          end
        end

        private

        def factory?(table_name)
          end_with = "/#{table_name}.rb"

          self.class.factories.any? { |path| path.end_with?(end_with) }
        end

        def self.factories
          @factories ||= Dir.glob("{,ee/,jh/}spec/factories/**/*.rb")
        end
      end
    end
  end
end
