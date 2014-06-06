require 'argumental'

class SubSubAction < Argumental::Action
    def initialize
        super "sub_sub_action", "This should be deeply nested"
    end

    def _run
        puts "Sub subaction running. If this works, the madness can begin."
        puts "Sub Sub opts: #{options}"
    end
end

class SubAction < Argumental::Action
    def initialize
        super "sub_action", "This should be nested"
        @subactions << SubSubAction.new
    end

    def _run
        puts "Subaction running"
        puts "Sub opts: #{options}"
    end
end

class BobAction < Argumental::Action
    def initialize
        super("bob_action", "Do Bob stuff", ARGV, '1.0.0')
        @option_definitions = [
            {name: :do_stuff, description: "Set if you want to do stuff"},
            {name: :mandatory, description: "Required"},
        ]
        @subactions << SubAction.new
    end

    def validate
        raise "No mandatory option" unless @options[:mandatory]
    end

    def _run
        puts "Hi I'm bob"
        puts "Opts: #{options}"
        puts "Do stuff" if @options[:do_stuff]
    end
end

BobAction.new.run




