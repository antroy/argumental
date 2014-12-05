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
            sub1 = TestAction.new "sub1", [subsub1], [{name: :sub_one, description: "Sub One", default: false}]
            TestAction.new "topper", [sub1], [{name: :top, description: "Top", type: String, default: 'nothing'}]
        }

        it 'should have no default options set' do
            subject.args = []
            subject.run
            subject.config[:top].should == 'nothing'
        end

        it 'should have default options set with strings as keys' do
            subject.args = []
            subject.apply_config({'top' => "A String Key"})
            subject.run
            subject.config[:top].should == 'A String Key'
        end

        it 'should have default options set with symbols as keys' do
            subject.args = []
            subject.apply_config({top: 'A Symbol Key'})
            subject.run
            subject.config[:top].should == 'A Symbol Key'
        end

        it 'should have default options overridden when passed in on commandline' do
            subject.args = ['--top', 'Command line magic']
            subject.apply_config({top: 'A Symbol Key'})
            subject.run
            subject.config[:top].should == 'Command line magic'
        end

        it 'should have dynamic preset use depending on option input' do
            subject.args = ['--top', 'Command line magic']
            subject.set_pre_validate do
                opts = options
                if options[:top]
                    apply_config({sub1: 'Dynamically assigned'})
                end
            end
            subject.run
            subject.config[:top].should == 'Command line magic'
            subject.config[:sub1].should == 'Dynamically assigned'
        end

        it 'should have default options available from subcommands' do
            subject.args = ['sub1']
            subject.apply_config({top: 'A Symbol Key'})
            subject.run
            sub = subject.subactions.first
            sub.config[:top].should == 'A Symbol Key'
        end

        it 'should have default options overridden from commandline available from subcommands' do
            subject.args = ['--top', 'Bernard', 'sub1']
            subject.apply_config({top: 'A Symbol Key'})
            subject.run
            sub = subject.subactions.first
            sub.config[:top].should == 'Bernard'
        end

        it 'should have default options work for subcommand options' do
            subject.args = ['sub1', '--sub-one']
            subject.apply_config({sub_one: 'A Symbol Sub One'})
            subject.run
            subject.config[:sub_one].should == true
            sub = subject.subactions.first
            sub.config[:sub_one].should == true
        end

        it 'should allow the setting of config not in the options' do
            subject.args = ['sub1', '--sub-one']
            subject.apply_config({invisible: 'A Symbol Sub One'})
            subject.run
            subject.config[:invisible].should == 'A Symbol Sub One'
            sub = subject.subactions.first
            sub.config[:invisible].should == 'A Symbol Sub One'
        end

        it 'config set directly is not affected by options' do
            subject.args = ['sub1', '--sub-one']
            subject.configuration = {'my' => 'new', 'clean' => 'hash'}
            subject.run
            sub = subject.subactions.first

            puts sub.configuration
            sub.configuration[:invisible].should == nil
            sub.configuration['my'].should == 'new'
            sub.configuration['clean'].should == 'hash'
        end
    end
end
