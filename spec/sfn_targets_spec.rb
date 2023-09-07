require 'spec_helper'

RSpec.describe "step function targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/step_function_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for sfn targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').exactly(1).times
    end

    it "points to specified step function explicitly" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:name, "PolyjuicePotion")
                         .with_attribute_value(:event_pattern, {"detail-type": ["command.MakePolyjuicePotion"]}.to_json)
    end
  end


  context "aws_cloudwatch_event_target" do
    it "creates for rules targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').exactly(1).times
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:arn, "arn:aws:states:us-east-1:123456789012:stateMachine:PolyJuicePotion")
                         .with_attribute_value(:event_bus_name, "the-knight-bus")
                         .with_attribute_value(:rule, "PolyjuicePotion")
    end
  end

  context "aws_iam_role" do
    it "creates iam role for target" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role').exactly(1).times
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy').exactly(1).times
    end

    it "permits only actions required" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy')
                         .with_attribute_value(:name, "invoke-sfn")
                         .with_attribute_value(:policy, include("states:StartExecution"))
    end
  end

  context "excludes" do
    it "does not create lambda permissions" do
      expect(@plan).not_to include_resource_creation(type: 'aws_lambda_permission')
    end
  end
end
