require 'trollop'

class Action
    attr_reader :name, :args
    attr_writer :option_definitions

    def initialize(name, help, args = ARGV)
        @name = name
        @help = help
        @option_definitions = []
        @subactions = []
        @args = args
        @completion_mode = false
    end

    def commands(depth=0)
        puts ("    " * depth) + @name
        @subactions.each{|act| act.commands(depth + 1)}
    end

    def manual(pre_commands=[])
        command_list = pre_commands + [@name]
        puts "#{command_list.join(' <options> ')} <options>\n\n"
        parser.educate
        puts
        @subactions.each{|act| act.manual(command_list)}
    end

    def parser
        return @parser if @parser

        opt_defs = @option_definitions
        help_text = @help
        the_subcommands = @subactions
        sub_help = @subactions.empty? ? "" : "\n\nSub Actions: " + @subactions.map{|sa| sa.name}.join(', ')

        @parser = Trollop::Parser.new do
            banner "#{help_text}#{sub_help}\n " if help_text and not @completion_mode

            opt :commands, "Display all commands", short: :none
            opt :man, "Display manual page", short: :none

            opt_defs.each do |option|
                name = option[:name]
                option.delete :name
                desc = option[:description]
                option.delete :description
                opt name, desc, option
            end
            stop_on the_subcommands.map{|comm| comm.name}
        end

        @parser
    end

    def validate
    end

    def options
        return @options if @options

        myself = self
        @options, @subaction = Trollop::with_standard_exception_handling(parser) do
            options = @parser.parse myself.args

            begin
                validate unless @completion_mode
            rescue
                raise Trollop::HelpNeeded
            end

            act = nil
            unless myself.args.empty?
                act = @subactions.find{|comm| comm.name == myself.args.shift}
                raise Trollop::HelpNeeded unless act
            end

            [options, act]
        end
        @options
    end

    def _run
        puts "No action defined. Create a _run method in your subclass"
    end

    def run
        options

        if options[:man]
            manual
            exit 0
        end

        if options[:commands]
            commands
            exit 0
        end

        if @subaction
            @subaction.options.concat options
            @subaction.run
        else
            _run
        end
    end
end
