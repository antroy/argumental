class SubSubAction < Action
    attr_reader :info, :subactions
    def initialize(args)
        super "sub_sub_action", "This should be deeply nested", args
        @info = nil
    end

    def _run
        @info = @options
    end
end


class SubAction < Action
    attr_reader :info, :subactions
    def initialize(args)
        super "sub_action", "This should be nested", args
        @subactions << SubSubAction.new(args)
        @info = nil
    end

    def _run
        @info = @options
    end
end

class TopAction < Action
    attr_reader :info, :subactions
    def initialize(args)
        super "top_action", "Do stuff", args
        @option_definitions = [
            {name: :do_stuff, description: "Set if you want to do stuff"}
        ]
        @subactions << SubAction.new(args)
        @info = nil
    end

    def _run
        @info = @options
    end
end

