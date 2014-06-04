
class VersionedAction < Action
    attr_reader :info, :subactions
    attr_accessor :args

    def initialize(name, subcommands=[], options=[], args=[])
        super name, "Desc for #{name}", args, '1.0.0'
        @subactions.concat subcommands
        @option_definitions = options
    end

    def _run
        @info = @options
    end
end
 
