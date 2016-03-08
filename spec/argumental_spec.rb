require 'spec_helper'
require 'support/subactions'
require 'support/noaction'
require 'support/testaction'
require 'support/versioned_action'
require 'support/non_versioned_action'

describe Argumental::Action do
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
            first_sub.options[:sub_one].should == true
        end

        it 'can see default options in the second subcommand' do
            subject.args = ['sub2']
            subject.run
            second_sub = subject.subactions[1]
            puts "SUB: #{second_sub.name}"
            second_sub.options[:sub_two].should == true
        end

        it 'runs the top level action with default options' do
            puts "TOP"
            act = TopAction.new []
            act.run
            act.info.should_not == nil
            act.info[:do_stuff].should == false
        end

        it 'runs the sub action' do
            act = TopAction.new ['sub_action']
            act.run
            act.info.should == nil

            sub = act.subactions.first

            sub.info.should_not == nil
        end

        it 'runs the sub-sub action' do
            act = TopAction.new ['sub_action', 'sub_sub_action']
            act.run
            act.info.should == nil

            sub = act.subactions.first
            sub_sub = sub.subactions.first

            sub.info.should == nil
            sub_sub.info.should_not == nil
        end
    end
    context 'command version' do
        context 'when specified' do
            subject { VersionedAction.new 'version', [] }
            it 'version is set' do
                subject.instance_variable_get(:@version).should == '1.0.0'
            end
        end
        context 'when not-specified' do           
            subject { NonVersionedAction.new 'versioned', [] }
            it 'version is nil' do
                subject.instance_variable_get(:@version).should == nil
            end 
        end
    end

    context '#commands' do
        context 'with 2 subcommands' do

            context 'and default params' do
                subject { @act = TopAction.new ['sub_action', 'sub_sub_action'] }
                it 'includes sub_action' do
                    capture_stdout { subject.commands }.should include('top_action')
                end
                it 'include sub_sub_action' do
                   capture_stdout { subject.commands }.should include("sub_action\n") 
                end
                it 'includes sub_sub_action' do
                   capture_stdout { subject.commands }.should include('sub_sub_action') 
                end
            end

            context 'and a depth of 2' do
                subject { @act = TopAction.new ['sub_action', 'sub_sub_action'] }
                it 'includes sub_action' do
                    capture_stdout { subject.commands(2) }.should include("        top_action\n")
                end
                it 'include sub_sub_action' do
                   capture_stdout { subject.commands(2) }.should include('sub_sub_action') 
                end
            end

        end
    end

    context '#manual' do
        subject { 
            TopAction.new ['sub_action', 'sub_sub_action']
        }
        it 'contains its own name' do
            subject.manual.should include('top_action')
        end
        it 'contains its subcommands' do
            subject.manual.should include('sub_sub_action')
        end
    end

    context '#completion' do
        subject { 
            TopAction.new ['sub_action', 'sub_sub_action']
        }
        it 'contains its args' do
            subject.autocompletion.should include('--man')
            subject.autocompletion.should include('--completion')
            subject.autocompletion.should include('--do-stuff')
        end
        it 'subaction contains its and its parents args' do
            sub = subject.subactions[0]
            sub.autocompletion.should include('--man')
            sub.autocompletion.should include('--completion')
            sub.autocompletion.should include('--do-stuff')
            sub.autocompletion.should include('--sub-do-stuff')
        end
        it 'contains its immediate subcommands' do
            subject.autocompletion.should include('sub_action')
        end
    end

    context '#run' do
        context 'with man option' do
            subject { TopAction.new ['sub_action', 'sub_sub_action', '--man'] }
            # Can't work out how to make this work with the shonky 
            # shell out to less...
            xit 'calls manual' do
                subject.should_receive(:manual)
                subject.should_not_receive(:_run)
                begin 
                    subject.run
                rescue SystemExit #required to allow for exit
                end
            end
        end
        context 'with commands option' do
            subject { TopAction.new ['sub_action', 'sub_sub_action', '--commands'] }
            # Again - implementation specific. Fix.
            it 'calls commands' do
                subject.subactions[0].subactions[0].should_receive(:commands)
                subject.should_not_receive(:_run)
                begin 
                    subject.run
                rescue SystemExit #required to allow for exit
                end
            end
        end
    end

    context 'with no action defined' do
        it 'outputs error' do
            act = NoAction.new []
            output = capture_stdout { act.run } 
            expect(output).to include("No action defined. Create a _run method in your subclass")
        end
    end
end
