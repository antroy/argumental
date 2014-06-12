
class TestAction < Argumental::Action
    attr_reader :info, :subactions

    def initialize(name, subcommands=[], opts=[], args=[])
        super name, "Desc for #{name}", args
        subcommands.each{|sub| add_subaction sub}

        @option_definitions = opts
    end

    def set_pre_validate(&block)
        @block = block
    end

    def args=(new_args)
        @_args = new_args
        @subactions.each{|sub| sub.args = new_args}
    end

    def pre_validate
        instance_eval(&@block) if @block
    end

    def _run
    end
end
 
