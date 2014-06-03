require 'spec_helper'
require 'support/subactions'
require 'support/noaction'
require 'support/testaction'
require 'support/versioned_action'
require 'support/non_versioned_action'

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
            subject { VersionedAction.new 'versioned', [] }
            it 'version is set' do
                subject.instance_variable_get(:@version).should == '1.0.0'
            end
        end
        context 'when not-specified' do           
            subject { NonVersionedAction.new 'versioned', [] }
            it 'version is set' do
                subject.instance_variable_get(:@version).should == '1.0.0'
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
                it 'sub_sub_action is indented correctly' do
                   capture_stdout { subject.commands }.should include("\n        sub_sub_action\n")  
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
        subject { @act = TopAction.new ['sub_action', 'sub_sub_action'] }
        it 'contains its own name' do
            capture_stdout {subject.manual }.should include('top_action')
        end
        it 'contains its subcommands' do
            capture_stdout {subject.manual }.should include('sub_sub_action')
        end
    end

    context '#run' do
        subject { @act = TopAction.new ['sub_action', 'sub_sub_action'] }
        context 'with man option' do
            it 'calls manual' do
                subject.should_receive(:options).at_least(:once).and_return({man:true})
                subject.should_receive(:manual)
                subject.should_not_receive(:_run)
                begin 
                    capture_stdout {subject.run}
                rescue SystemExit #required to allow for exit
                end
            end
            it 'system exists' do
               subject.should_receive(:options).at_least(:once).and_return({man:true})
                subject.should_receive(:manual).with(no_args)
                expect { capture_stdout {subject.run} }.to raise_error(SystemExit)
            end
        end
        context 'with commands option' do
            it 'calls manual' do
                subject.should_receive(:options).at_least(:once).and_return({commands:true})
                subject.should_receive(:commands).with(no_args)
                subject.should_not_receive(:_run)
                begin 
                    capture_stdout {subject.run}
                rescue SystemExit #required to allow for exit
                end
            end
            it 'system exists' do
               subject.should_receive(:options).at_least(:once).and_return({man:true})
                subject.should_receive(:manual)
                expect { capture_stdout {subject.run} }.to raise_error(SystemExit)
            end
        end
    end

    context '#options' do
        subject { @act = TopAction.new ['sub_action', 'sub_sub_action'] }
        context 'invalid validation' do
            xit 'raise Trollop:HelpNeeded' do
                $stdout = StringIO.new
                subject.should_receive(:validate).and_raise(RuntimeError)
                subject.instance_variable_get(:@completion_mode).should == false
                lambda { subject.options}.should raise_exception(Trollop::HelpNeeded)
            end
        end
    end

    context 'with no action defined' do
        it 'outputs error' do
            act = NoAction.new []
            output = capture_stdout { act.run } 
            output.should == "No action defined. Create a _run method in your subclass\n"
        end
    end
end
