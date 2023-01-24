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
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').twice
    end

    it "points to specified bus" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule')
        .with_attribute_value(:event_pattern, "{\"detail-type\":[\"event.DementorsAppear\"]}")
    end

    context "bus rules" do
      let(:event_rule) { event_rules.first.change.after }

      it "configures the rule" do
        expect(event_rule[:name]).to eq("event.DementorsAppear")
        expect(event_rule[:event_pattern]).to eq({"detail-type": ["event.DementorsAppear"]}.to_json)
        expect(event_rule[:event_bus_name]).to eq("the-knight-bus")
      end
    end

    context "multiple lambda targets" do
      let(:permissions) { @plan.resource_changes_matching(type: "aws_lambda_permission") }
      let(:permission) { permissions[1].change.after }

      it "sets permissions for each target lambda" do
        expect(permissions.count).to eq(4)
        expect(permission[:action]).to eq("lambda:InvokeFunction")
        expect(permission[:function_name]).to eq("summonHermione")
        expect(permission[:principal]).to eq("events.amazonaws.com")
      end
    end

    context "event targets" do
      let(:targets) { @plan.resource_changes_matching(type: "aws_cloudwatch_event_target") }
      let(:target) { targets.first.change.after }

      it "sets permissions for each target lambda" do
        expect(targets.count).to eq(5)
        expect(target[:arn]).to eq("arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic")
        expect(target[:rule]).to eq("event.DementorsAppear")
        expect(target[:event_bus_name]).to eq("the-knight-bus")
      end
    end
  end
end