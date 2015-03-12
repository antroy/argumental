require 'trollop'

module Argumental
    class Action
        attr_reader :name
        attr_writer :option_definitions
        attr_accessor :parent

        def initialize(name, help, args = ARGV, version=nil)
            @name = name
            @help = help
            @option_definitions = []
            @subactions = []
            @_args = args
            @version = version
            @completion_mode = false
            @parent = nil
            @configuration = {}
        end

        def args
            name = @name
            out = @_args.find_all do |arg|
                names = @subactions.map {|sa| sa.name}
                name != arg  && ! names.include?(arg)
            end
            out
        end

        def current_subaction
            out = @subactions.find_all{|sa| @_args.include?(sa.name)}
            raise "Can't invoke more than one subaction but #{out.join(", ")} provided." if out.size > 1
            out.empty? ? nil : out.first
        end

        def version
            if @parent
                @parent.version
            else
                @version
            end
        end
        # check if the option with the supplied name is in the supplied option hash
        def check_option(opt, opts, msg = "#{opt.to_s} option must be specified")
            raise msg if opts[opt] == nil
        end

        def add_subaction(action)
            @subactions << action
            action.parent = self
        end

        def symbolize(hash)
            hash.inject({}) do |out,(k,v)|
                out[k.to_sym] = v
                out
            end
        end

        def apply_config(preset_hash)
            symbolized_hash = symbolize(preset_hash)
            configuration.merge! symbolized_hash
        end

        def configuration
            @parent ? @parent.configuration : @configuration
        end

        def configuration=(hash)
            if @parent
                @parent.configuration = hash
            else
                @configuration = hash
            end
        end

        def option_definitions
            out = @option_definitions.map{|o| o.clone}
            out.concat @parent.option_definitions if @parent
            out
        end

        def config
            out = {}
            configuration.keys.each do |k|
                if options.has_key?(k) && options["#{k}_given".to_sym]
                    out[k] = options[k]
                else
                    out[k] = configuration[k]
                end
                out
            end

            options.keys.each do |k|
                unless out.has_key?(k)
                    out[k] = options[k]
                end
            end

            out
        end

        def commands(depth=0)
            puts "%s %s" % [("    " * depth), @name]
            @subactions.each{|act| act.commands(depth + 1)}
        end

        def colourize(text, color_code); "\e[#{color_code}m#{text}\e[0m" end
        def green(text); colourize(text, 32) end
        def ggreen(text); bold green text end
        def yellow(text); colourize(text, 33) end
        def yyellow(text); bold yellow text end
        def blue(text); colourize(text, 34) end
        def bblue(text); bold blue text end
        def bold(text); colourize(text, 1) end

        def manual(pre_commands=[])
            out = ""
            command_list = pre_commands + [@name]
            title = command_list.join(' / ').upcase
            title = title + "\n" + "-" * title.size
            out = out + yyellow(title) + "\n"
            command_syntax = ("#{command_list.join(' <options> ')} <options>\n" + "\n")
            out = out + bblue(command_syntax)
            require 'stringio'
            old_stdout = $stdout
            $stdout = StringIO.new
            parser.educate
            if $stdout.string =~ /(.*)(Sub Actions:)(.*)/m
             education = $1.to_s + bblue($2.to_s) + blue($3.to_s)
            else
              education= $stdout.string
            end
            $stdout = old_stdout
            out = out + education.strip + "\n"
            @subactions.each{|act| out = out + act.manual(command_list)}
            out
        end

        def parser(parent_opt_defs = [])

            return @parser if @parser

            help_text = @help

            sub_help = @subactions.empty? ? "" : "\n\nSub Actions: " + @subactions.map{|sa| sa.name}.join(', ')
            app_version = version
            opt_defs = option_definitions

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
            end

            @parser
        end

        def _opt_cache=(opts)
            if @parent
                @parent._opt_cache=(opts)
            else
                @options = opts
            end
        end

        def _opt_cache
            if @parent
                @parent._opt_cache
            else
                @options
            end
        end

        def options
            return _opt_cache if _opt_cache

            myself = self
            Trollop::with_standard_exception_handling(parser) do
                parser_opts = @parser.parse myself.args
                myself._opt_cache = parser_opts
            end

            _opt_cache
        end

        def pre_validate
        end

        def _pre_validate
            if @parent
                @parent._pre_validate
            end
            pre_validate
        end

        def validate
        end

        def _validate
            if @parent
                @parent._validate
            end
            validate
        end

        def _run
            puts "No action defined. Create a _run method in your subclass"
        end

        def run
            if current_subaction
                current_subaction.run
            else
                options
                _pre_validate

                if options[:man]
                    String.colour_on = true
                    out = manual
                    IO.popen("less -R", "w") { |f| f.puts out }
                    exit 0
                end

                if options[:commands]
                    commands
                    exit 0
                end

                begin
                    _validate unless @completion_mode
                rescue StandardError => ex
                    puts "\nERROR: #{ex.message}\n\n"
                    puts "Usage:\n"
                    parser.educate
                    exit 1
                end

                _run
            end
        end
    end
end
