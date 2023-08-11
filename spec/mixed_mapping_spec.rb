require 'spec_helper'

RSpec.describe "mixed configuration tests" do
  before :all do
    @plan = plan(configuration_directory: 'examples/mixed_targets')
  end

  it "renders a plan without errors" do
    expect(@plan).to be_a(RubyTerraform::Models::Plan)
  end

  context "disabled" do
    let(:target) { "module.disabled" }

    it "creates a disabled rule" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
        .once
        .with_attribute_value(:is_enabled, false)
    end
  end

  context "multi-target" do
    let(:target) { "module.multi-target" }

    it "creates event rules without filters" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "detail-type": ["event.DementorsAppear"]
                         }.to_json)
    end

    it "creates event targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: target).exactly(4).times
    end

    it "creates lambda permissions" do
      expect(@plan).to include_resource_creation(type: 'aws_lambda_permission', module_address: target).exactly(2).times
    end

    # Fix this
    xit "outputs the event rule arn" do
      expect(@plan).to include_output(value: 'event_rule_arn')
    end
  end

  context "added-filters" do
    let(:target) { "module.added-filters" }

    it "can create additional filters against details" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "account": %w[123456789012 098765432109],
                           "detail": {
                             "class": ["unforgivable"],
                             "type": ["curse"]
                           },
                           "detail-type": ["event.SpellCast"]
                         }.to_json)
    end
  end

  context "any-events" do
    let(:target) { "module.any-events" }

    it "can capture all events" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "detail-type": [ { "prefix": "" } ]
                         }.to_json)
    end
  end

  context "ignored-accounts" do
    let(:target) { "module.ignored-accounts" }

    it "can filter out accounts" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "account": { "anything-but": %w[2828282828282 949494949494] },
                           "detail-type": [ "speak:RoomOfRequirement" ]
                         }.to_json)
    end
  end
end
