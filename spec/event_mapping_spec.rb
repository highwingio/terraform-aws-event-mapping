require 'spec_helper'

RSpec.describe "event_mapping" do
  before :all do
    @plan = plan(configuration_directory: 'examples')
  end

  it "renders a plan without errors" do
    expect(@plan).to be_a(RubyTerraform::Models::Plan)
  end

  context "resource creation" do
    let(:event_rules) { @plan.resource_changes_matching(type: "aws_cloudwatch_event_rule") }

    it "creates aws_cloudwatch_event_rules for bus targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').exactly(3).times
    end

    it "points to specified bus" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                         .with_attribute_value(:event_pattern, "{\"detail-type\":[\"event.DementorsAppear\"]}")
    end

    context "bus rules" do
      it "configures the rule" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
                           .with_attribute_value(:name, "event.DementorsAppear")
                           .with_attribute_value(:event_pattern, { "detail-type": ["event.DementorsAppear"] }.to_json)
                           .with_attribute_value(:event_bus_name, "the-knight-bus")
      end
    end

    context "multiple lambda targets" do
      it "creates permissions for each lambda" do
        expect(@plan).to include_resource_creation(type: 'aws_lambda_permission').exactly(4).times
      end

      it "sets permissions for each target lambda" do
        expect(@plan).to include_resource_creation(type: 'aws_lambda_permission')
                           .with_attribute_value(:action, "lambda:InvokeFunction")
                           .with_attribute_value(:function_name, "summonHermione")
                           .with_attribute_value(:principal, "events.amazonaws.com")
      end
    end

    context "event targets" do
      it "creates targets for each lambda target" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                           .exactly(7).times
      end

      it "sets permissions for each target lambda" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                           .with_attribute_value(:arn, "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic")
                           .with_attribute_value(:rule, "event.DementorsAppear")
                           .with_attribute_value(:event_bus_name, "the-knight-bus")
      end
    end
  end
end