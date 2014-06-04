require 'trollop'

class Action
    attr_reader :name
    attr_writer :option_definitions
    attr_accessor :parent, :args

    def initialize(name, help, args = ARGV, version=nil)
        @name = name
        @help = help
        @option_definitions = []
        @subactions = []
        @args = args
        @version = version
        @completion_mode = false
        @parent = nil
        @presets = {}
    end

    # check if the option with the supplied name is in the supplied option hash
    def check_option(opt, opts, msg = "#{opt.to_s} option must be specified")
        raise msg if opts[opt] == nil
    end

    def add_subaction(action)
        @subactions << action
        action.parent = self
        action.args = @args
    end

    def apply_presets(presets)
        raise "Cannot apply presets on sub actions" if @parent

        @presets.merge! presets
    end

    def presets
        @parent ? @parent.presets : @presets
    end

    def apply_presets_to_definitions
        @option_definitions.each do |opt|
            name = opt[:name]
            if presets.has_key?(name.to_s)
                opt[:default] = presets[name.to_s]
            elsif presets.has_key?(name.to_sym)
                opt[:default] = presets[name.to_sym]
            end
        end
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

        opt_defs = apply_presets_to_definitions
        
        help_text = @help
        the_subcommands = @subactions
        sub_help = @subactions.empty? ? "" : "\n\nSub Actions: " + @subactions.map{|sa| sa.name}.join(', ')
        app_version = @version

        @parser = Trollop::Parser.new do
            banner "#{help_text}#{sub_help}\n " if help_text and not @completion_mode
            version app_version if app_version

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
        Trollop::with_standard_exception_handling(parser) do
            parser_opts = @parser.parse myself.args
            @options = parser_opts

            unless myself.args.empty?
                sub_command = myself.args.shift
                @subaction = @subactions.find{|comm| comm.name == sub_command}
                raise Trollop::HelpNeeded unless @subaction
            end
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


        begin
            validate unless @completion_mode
        rescue StandardError => ex
            puts "ERROR: #{ex.message}"
            parser.educate
        end

        if @subaction
            @subaction.options.merge!(options)
            @subaction.run
        else
            _run
        end
    end
end
