require 'spec_helper'

RSpec.describe "appsync targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/appsync_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for bus targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').once
    end
  end

  context "aws_cloudwatch_event_target" do
    it "creates for rules targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').once
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:rule, "event.FightBasilisk")
                         .with_attribute_value([:input_transformer, 0, :input_paths], {
                           bring: "$.detail.bring",
                           healing: "$.detail.phoenix_tears",
                           location: "$.detail.location",
                           urgency: "$.detail.urgency"
                         })
                         .with_attribute_value([:input_transformer, 0, :input_template],
                                               JSON.pretty_generate({
                                                                      detail: {
                                                                        location: "Chamber of Secrets",
                                                                        urgency: "Life or Death",
                                                                        bring: ["Sword of Gryffindor", "Sorting Hat"],
                                                                        phoenix_tears: "Yes"
                                                                      }
                                                                    }) + "\n")
    end

    it "specifies gql response" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value([:appsync_target, 0, :graphql_operation],
                                               "mutation CreateEmergency($input: CreateEmergencyInput!) { createEmergency(input: $input) {\n  message\n  status\n  eta\n}\n}")
    end
  end

  context "aws_iam_role" do
    it "creates iam role for target" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role').exactly(1).times
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy').exactly(1).times
    end

    it "permits only actions required" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy')
                         .with_attribute_value(:name, "invoke-appsync")

      # can't currently validate this because the policy is generated based on the ARNs created by
      # other resources
      # .with_attribute_value(:policy, include("events:InvokeApiDestination"))

    end
  end

  context "excludes" do
    it "does not create lambda permissions" do
      expect(@plan).not_to include_resource_creation(type: 'aws_lambda_permission')
    end
  end
end
