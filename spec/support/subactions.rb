class SubSubAction < Argumental::Action
    attr_reader :info, :subactions
    def initialize(args)
        super "sub_sub_action", "This should be deeply nested", args
        @option_definitions = [
            {name: :sub_sub_do_stuff, description: "Set if you want to do stuff"}
        ]
        @info = nil
    end

    def _run
        @info = options
    end
end


class SubAction < Argumental::Action
    attr_reader :info, :subactions
    def initialize(args)
        super "sub_action", "This should be nested", args
        @option_definitions = [
            {name: :sub_do_stuff, short: '-s', description: "Set if you want to do stuff"}
        ]
        add_subaction SubSubAction.new(args)
        @info = nil
    end

    def _run
        @info = options
    end
end

class TopAction < Argumental::Action
    attr_reader :info, :subactions
    def initialize(args)
        super "top_action", "Do stuff", args
        @option_definitions = [
            {name: :do_stuff, description: "Set if you want to do stuff"}
        ]
        add_subaction SubAction.new(args)
        @info = nil
    end

    def _run
        @info = options
    end
end

