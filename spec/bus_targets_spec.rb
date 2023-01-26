require 'spec_helper'

RSpec.describe "event bus targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/bus_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for bus targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').exactly(1).times
    end

    it "points to specified bus ane names explicitly" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:event_pattern, {"detail-type": ["event.DementorsAppear", "event.UnderAgedMagicDone"]}.to_json)
    end

    it "name defaults to first rule when not specified" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:name, "event.DementorsAppear")

      expect(@plan).not_to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                             .with_attribute_value(:name, "event.UnderAgedMagicDone")
    end
  end


  context "aws_cloudwatch_event_target" do
    it "creates for rules targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').exactly(1).times
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:arn, "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic")
                         .with_attribute_value(:event_bus_name, "the-knight-bus")
                         .with_attribute_value(:rule, "event.DementorsAppear")
    end
  end

  context "excludes" do
    it "does not create lambda permissions" do
      expect(@plan).not_to include_resource_creation(type: 'aws_lambda_permission')
    end
  end
end