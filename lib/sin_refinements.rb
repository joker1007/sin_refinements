require "sin_refinements/version"

require 'parser/current'
require 'proc_to_ast'
require 'binding_ninja'

module SinRefinements
  class << self
    extend BindingNinja

    def get_local_variable_names(ast, buf = [])
      if ast.type == :send
        params = ast.to_a
        if params[0].nil? && params.length == 2
          buf << params[1]
        end
      end

      ast.children.each do |node|
        if node.is_a?(Parser::AST::Node)
          get_local_variable_names(node, buf)
        end
      end

      buf
    end

    auto_inject_binding def refining(b, mod, &block)
      block_source = block.to_source
      matched = block_source.match(/do(.*)end/m)
      proc_source = "proc #{matched[0]}"
      used_local_variables = get_local_variable_names(Parser::CurrentRuby.parse(matched[1]))

      c = TOPLEVEL_BINDING.eval(<<~RUBY)
        Class.new do
          using #{mod.to_s}

          def self.process(b)
            #{b.local_variables.select { |v| used_local_variables.include?(v) }.map { |v| "#{v} = b.local_variable_get(:#{v})" }.join("\n")}
            pr = #{proc_source}
            b.receiver.instance_exec(&pr)
          end
        end
      RUBY
      c.process(b)
    end

    def refined_class_table
      @refined_class_table ||= Hash.new { |h, k| h[k] = {} }
    end

    auto_inject_binding def light_refining(b, mod, *variables, &block)
      source_location = block.source_location
      unless refined_class_table[source_location][mod]
        block_source = block.to_source
        matched = block_source.match(/do(.*)end/m)
        proc_source = "proc #{matched[0]}"

        refined_class_table[source_location][mod] = TOPLEVEL_BINDING.eval(<<~RUBY)
          Class.new do
            using #{mod.to_s}

            def self.process(b, *variables)
              pr = #{proc_source}
              b.receiver.instance_exec(*variables, &pr)
            end
          end
        RUBY
      end
      refined_class_table[source_location][mod].process(b, *variables)
    end
  end
end
