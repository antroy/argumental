
class NonVersionedAction < Argumental::Action
    attr_reader :info, :subactions
    attr_accessor :args

    def initialize(name, subcommands=[], options=[], args=[])
        super name, "Desc for #{name}", args
        @subactions.concat subcommands
        @option_definitions = options
    end

    def _run
        @info = @options
    end
end
 
