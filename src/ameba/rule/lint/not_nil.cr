module Ameba::Rule::Lint
  # This rule is used to identify usages of `not_nil!` calls.
  #
  # For example, this is considered a code smell:
  #
  # ```
  # names = %w[Alice Bob]
  # alice = names.find { |name| name == "Alice" }.not_nil!
  # ```
  #
  # And can be written as this:
  #
  # ```
  # names = %w[Alice Bob]
  # alice = names.find { |name| name == "Alice" }
  #
  # if alice
  #   # ...
  # end
  # ```
  #
  # YAML configuration example:
  #
  # ```
  # Lint/NotNil:
  #   Enabled: true
  # ```
  class NotNil < Base
    include AST::Util

    properties do
      description "Identifies usage of `not_nil!` calls"
    end

    NOT_NIL_NAME = "not_nil!"
    MSG          = "Avoid using `not_nil!`"

    def test(source)
      AST::NodeVisitor.new self, source, skip: [
        Crystal::Macro,
        Crystal::MacroExpression,
        Crystal::MacroIf,
        Crystal::MacroFor,
      ]
    end

    def test(source, node : Crystal::Call)
      return unless node.name == NOT_NIL_NAME
      return unless node.obj && node.args.empty?

      return unless name_location = node.name_location
      return unless end_location = name_end_location(node)

      issue_for name_location, end_location, MSG
    end
  end
end
