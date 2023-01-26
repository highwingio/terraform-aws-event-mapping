require 'spec_helper'

RSpec.describe "mixed configuration tests" do
  before :all do
    @plan = plan(configuration_directory: 'examples/mixed_targets')
  end

  it "renders a plan without errors" do
    expect(@plan).to be_a(RubyTerraform::Models::Plan)
  end

  it "creates event rules" do
    expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').once
  end

  it "creates event targets" do
    expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').exactly(3).times
  end

  it "creates lambda permissions" do
    expect(@plan).to include_resource_creation(type: 'aws_lambda_permission').exactly(2).times
  end
end