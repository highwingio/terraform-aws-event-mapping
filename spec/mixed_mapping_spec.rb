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

    context "aws_iam_role" do
      it "creates iam role for target" do
        expect(@plan).to include_resource_creation(type: 'aws_iam_role', module_address: target).exactly(1).times
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target).exactly(3).times
      end

      it "permits only actions required" do
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target)
                           .with_attribute_value(:name, "invoke-lambda")
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target)
                           .with_attribute_value(:name, "invoke-bus")
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target)
                           .with_attribute_value(:name, "invoke-sqs")
      end
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

    it "permits resources properly" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target).exactly(2).times

      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target)
                         .with_attribute_value(:name, "invoke-lambda")
                         .with_attribute_value(:policy, include("function:Duck", "function:Dodge", "function:Weave"))

      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: target)
                         .with_attribute_value(:name, "invoke-bus")
                         .with_attribute_value(:policy, include("event-bus/ministryOfMagic"))
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
    let(:current_account) { @plan.to_h.dig(:prior_state, :values, :root_module, :resources, 0, :values, :account_id) }

    it "can filter out accounts and includes caller account when designated" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "account": { "anything-but": ["2828282828282", "949494949494", current_account] },
                           "detail-type": [ "speak:RoomOfRequirement" ]
                         }.to_json)
    end
  end

  context "ignored-self" do
    let(:target) { "module.ignored-self" }
    let(:current_account) { @plan.to_h.dig(:prior_state, :values, :root_module, :resources, 0, :values, :account_id) }

    it "can filter caller account only" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule', module_address: target)
                         .once
                         .with_attribute_value(:event_pattern, {
                           "account": { "anything-but": [current_account] },
                           "detail-type": [ "speak:RoomOfRequirement" ]
                         }.to_json)
    end
  end
end
