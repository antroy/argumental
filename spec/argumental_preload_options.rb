require 'spec_helper'
require 'support/subactions'
require 'support/noaction'
require 'support/testaction'
require 'support/versioned_action'
require 'support/non_versioned_action'

describe Action do

    context 'Top level options are available' do
		subject { 
            subsub1 = TestAction.new "subsub1"
            sub1 = TestAction.new "sub1", [subsub1], [{name: :sub_one, description: "Sub One", default: false}]
            TestAction.new "topper", [sub1], [{name: :top, description: "Top", type: String, default: 'nothing'}]
        }

        it 'should have no default options set' do
            subject.args = []
            subject.run
            subject.info[:top].should == 'nothing'
        end

        it 'should have default options set with strings as keys' do
            subject.args = []
            subject.apply_presets({'top' => "A String Key"})
            subject.run
            subject.info[:top].should == 'A String Key'
        end

        it 'should have default options set with symbols as keys' do
            subject.args = []
            subject.apply_presets({top: 'A Symbol Key'})
            subject.run
            subject.info[:top].should == 'A Symbol Key'
        end

        it 'should have default options overridden when passed in on commandline' do
            subject.args = ['--top', 'Command line magic']
            subject.apply_presets({top: 'A Symbol Key'})
            subject.run
            subject.info[:top].should == 'Command line magic'
        end

        it 'should have dynamic preset use depending on option input' do
            subject.args = ['--top', 'Command line magic']
            subject.set_pre_validate do
                if options[:top]
                    apply_presets({sub1: 'Dynamically assigned'})
                end
            end
            subject.run
            subject.info[:top].should == 'Command line magic'
            subject.info[:sub1].should == 'Dynamically assigned'
        end

        it 'should have dynamic not preset since dependant option missing' do
            subject.args = []
            subject.set_pre_validate do
                if options[:top]
                    apply_presets({sub1: 'Dynamically assigned'})
                end
            end
            subject.run
            subject.info[:top].should == 'nothing'
            subject.info[:sub1].should == false
        end

        it 'should have default options available from subcommands' do
            subject.args = ['sub1']
            subject.apply_presets({top: 'A Symbol Key'})
            subject.run
            sub = subject.subactions.first
            sub.info[:top].should == 'A Symbol Key'
        end

        it 'should have default options overridden from commandline available from subcommands' do
            subject.args = ['--top', 'Bernard', 'sub1']
            subject.apply_presets({top: 'A Symbol Key'})
            subject.run
            sub = subject.subactions.first
            sub.info[:top].should == 'Bernard'
        end

        it 'should have default options work for subcommand options' do
            subject.args = ['sub1', '--sub-one', 'Brian' ]
            subject.apply_presets({sub_one: 'A Symbol Sub One'})
            subject.run
            sub = subject.subactions.first
            sub.info[:sub_one].should == 'Brian'
        end
    end
end
