require 'argumental'
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

describe Action do
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
