require 'spec_helper'

RSpec.describe "lambda targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/lambda_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for lambda targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').exactly(2).times
    end

    it "defines event patterns" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:event_pattern, {"detail-type": ["event.BoggartAppear", "event.DementorAppear"]}.to_json)

      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:event_pattern, {"detail-type": ["event.MalfoyAttacks"]}.to_json)
    end

    it "name defaults to first rule when not specified" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:name, "event.MalfoyAttacks")

      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:name, "getSomeMagic")

      expect(@plan).not_to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                             .with_attribute_value(:name, "event.DementorAppear")
    end

    it "enables the rule by default" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:state, "ENABLED")
    end
  end

  context "aws_cloudwatch_event_target" do
    it "creates targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').exactly(3).times
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:arn, "arn:aws:lambda:us-east-1:123456789012:function:summonRon")
                         .with_attribute_value(:event_bus_name, "the-knight-bus")
                         .with_attribute_value(:rule, "event.MalfoyAttacks")

      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:arn, "arn:aws:lambda:us-east-1:123456789012:function:summonHermione")
                         .with_attribute_value(:rule, "event.MalfoyAttacks")

      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:arn, "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus")
                         .with_attribute_value(:rule, "getSomeMagic")
    end
  end

  context "aws_iam_role" do
    it "does not create iam role for target" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role').exactly(0).times
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy').exactly(0).times
    end
  end

  context "aws_lambda_permission" do
    it "creates lambda permissions" do
      expect(@plan).to include_resource_creation(type: 'aws_lambda_permission').exactly(3).times
    end

    it "specifies permissions" do
      expect(@plan).to include_resource_creation(type: 'aws_lambda_permission')
                         .with_attribute_value(:action, "lambda:InvokeFunction")
                         .with_attribute_value(:function_name, "patronus")
                         .with_attribute_value(:principal, "events.amazonaws.com")
    end
  end
end
