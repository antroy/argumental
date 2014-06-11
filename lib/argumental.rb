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
            @presets = {}
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

        def set_option_defaults(preset_hash)
            presets.merge! preset_hash
        end

        def presets
            @parent ? @parent.presets : @presets
        end

        def option_definitions
            out = @option_definitions.map{|o| o.clone}
            out.concat @parent.option_definitions if @parent
            out
        end

        def apply_defaults_to_options
            options.keys.each do |key|
                unless options["#{key}_given".to_sym]
                    if presets.has_key?(key.to_s)
                        options[key] = presets[key.to_s]
                    elsif presets.has_key?(key.to_sym)
                        options[key] = presets[key.to_sym]
                    end
                end
            end
        end

        def commands(depth=0)
            puts "%s %s" % [("    " * depth), @name]
            @subactions.each{|act| act.commands(depth + 1)}
        end

        def manual(pre_commands=[])
            command_list = pre_commands + [@name]
            puts "=" * 40
            title = command_list.join(' / ').upcase
            puts title
            puts "-" * title.size
            puts
            puts "#{command_list.join(' <options> ')} <options>\n\n"
            parser.educate
            puts
            @subactions.each{|act| act.manual(command_list)}
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

                apply_defaults_to_options

                if options[:man]
                    manual
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
