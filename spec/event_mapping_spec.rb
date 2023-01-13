require 'spec_helper'

RSpec.describe "event_mapping" do
  before :all do
    @plan = terraform_plan
  end

  it "renders a plan without errors" do
    expect(@plan).to be_a(RubyTerraform::Models::Plan)
  end

  context "resource creation" do
    let(:event_rules) { @plan.resource_changes_matching(type: "aws_cloudwatch_event_rule") }

    it "creates aws_cloudwatch_event_rules for bus targets" do
      expect(event_rules.count).to eq(2)
      expect(event_rules).to all(be_create)
    end

    context "bus rules" do
      let(:event_rule) { event_rules.first.change.after }

      it "configures the rule" do
        expect(event_rule[:name]).to eq("event.DementorsAppear")
        expect(event_rule[:event_pattern]).to eq({"detail-type": ["event.DementorsAppear"]}.to_json)
        expect(event_rule[:event_bus_name]).to eq("the-knight-bus")
      end
    end
  end
end