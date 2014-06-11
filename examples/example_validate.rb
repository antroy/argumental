require 'argumental'

class SubSubAction < Argumental::Action
    def initialize
        super "sub_sub_action", "This should be deeply nested"
        @option_definitions = [
            {name: :sub_sub_option, short: 'z', description: "Sub Sub Option"},
        ]
    end

    def _run
        puts "Sub subaction running. If this works, the madness can begin."
        puts "Sub Sub opts: #{options}"
    end
end

class SubAction < Argumental::Action
    def initialize
        super "sub_action", "This should be nested"
        @option_definitions = [
            {name: :sub_option, short: 'x', description: "Sub Option"},
        ]
        add_subaction SubSubAction.new
    end

    def _run
        puts "Subaction running"
        puts "Sub opts: #{options}"
    end
end

class SideAction < Argumental::Action
    def initialize
        super "side_action", "This should be nested alongside sub_action"
        @option_definitions = [
            {name: :side_option, short: 'q', description: "Side Option"},
        ]
    end

    def _run
        puts "Sideaction running"
        puts "Side opts: #{options}"
    end
end

class BobAction < Argumental::Action
    def initialize
        super("bob_action", "Do Bob stuff", ARGV, '1.0.0')
        @option_definitions = [
            {name: :do_stuff, description: "Set if you want to do stuff"},
            {name: :mandatory, description: "Required"},
        ]
        add_subaction SubAction.new
        add_subaction SideAction.new
    end

    def pre_validate
        set_option_defaults({mandatory: true})
    end

    def validate
        raise "No 'mandatory' option provided" unless options[:mandatory]
    end

    def _run
        puts "Hi I'm bob"
        puts "Opts: #{options}"
        puts "Do stuff" if @options[:do_stuff]
    end
end

BobAction.new.run




