
class TestAction < Argumental::Action
    attr_reader :info, :subactions

    def initialize(name, subcommands=[], options=[], args=[])
        super name, "Desc for #{name}", args
        subcommands.each{|sub| add_subaction sub}

        @option_definitions = options
    end

    def set_pre_validate(&block)
        @pre_run_block = block
    end

    def args=(new_args)
        @args = new_args
        @subactions.each{|sub| sub.args = new_args}
    end

    def pre_validate
        @block.call if @block
    end

    def _run
        @info = @options
    end
end
 
