require 'spec_helper'
require 'support/subactions'
require 'support/noaction'
require 'support/testaction'
require 'support/versioned_action'
require 'support/non_versioned_action'

describe Argumental::Action do

    context 'Top level options are available' do
		subject { 
            subsub1 = TestAction.new "subsub1"
            subsub2 = TestAction.new "subsub2"
            sub1 = TestAction.new "sub1", [], [{name: :sub_one, description: "Sub One", default: false}]
            sub2 = TestAction.new "sub2", [subsub1, subsub2], [{name: :sub_two, description: "Sub Two", default: false}]
            TestAction.new "topper", [sub1, sub2], [{name: :top, description: "Top", default: false}]
        }

        it 'should have no options set when passed in on commandline' do
            subject.args = []
            subject.run
            subject.options[:top].should == false
        end

        it 'should have the top option set when passed in on commandline' do
            subject.args = ['--top']
            subject.run
            subject.options[:top].should == true
        end

        it 'should have the top option set when passed in on commandline' do
            subject.args = ['--top', 'sub1']
            subject.run
            subject.subactions.first.options[:top].should == true
       end

        it 'should be turtles all the way down...' do
            subject.args = ['--top', 'sub2', 'subsub2']
            subject.run
            second_child = subject.subactions[1]
            second_child.name.should == 'sub2'
            second_sub_child = second_child.subactions[1]
            second_sub_child.name.should == 'subsub2'
            second_sub_child.options[:top].should == true
        end
    end
end
