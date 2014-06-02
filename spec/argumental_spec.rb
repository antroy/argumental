require 'spec_helper'

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

class TestAction < Action
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

describe Action do
	context 'Two subcommands no nesting' do
		subject { 
            sub1 = TestAction.new "sub1", [], [{name: :sub_one, description: "Sub One", default: true}]
            sub2 = TestAction.new "sub2", [], [{name: :sub_two, description: "Sub Two", default: true}]
            TestAction.new "topper", [sub1, sub2]
        }

        it 'can see default options in the first subcommand' do
            subject.args = ['sub1']
            subject.run
            first_sub = subject.subactions.first
            puts "SUB: #{first_sub.name}"
            first_sub.info[:sub_one].should == true
        end

        it 'can see default options in the second subcommand' do
            subject.args = ['sub2']
            subject.run
            second_sub = subject.subactions[1]
            puts "SUB: #{second_sub.name}"
            second_sub.info[:sub_two].should == true
        end
    end

    it 'runs the top level action with default options' do
        puts "TOP"
        act = TopAction.new []
        act.run
        act.info.should_not == nil
        act.info[:do_stuff].should == false
    end

    it 'runs the sub action with default options' do
        puts "SUB"
        act = TopAction.new ['sub_action']
        act.run
        act.info.should == nil

        sub = act.subactions.first

        sub.info.should_not == nil
    end

    it 'runs the sub-sub action with default options' do
        puts "SUB SUB"
        act = TopAction.new ['sub_action', 'sub_sub_action']
        act.run
        act.info.should == nil

        sub = act.subactions.first
        sub_sub = sub.subactions.first

        sub.info.should == nil
        sub_sub.info.should_not == nil
    end
end
