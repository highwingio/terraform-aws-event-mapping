require 'spec_helper'

RSpec.describe "appsync targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/appsync_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for bus targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').twice
    end
  end

  context "aws_cloudwatch_event_target" do
    context "for explicit input mapping" do
      it "creates for rules targets" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_explicit').once
      end

      it "specifies targets" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_explicit')
                           .with_attribute_value(:rule, "event.FightBasilisk")
                           .with_attribute_value(:arn, "arn:aws:appsync:us-east-1:123456789012:endpoints/graphql-api/lotsofdigitsandchars")
                           .with_attribute_value([:input_transformer, 0, :input_paths], {
                             bring: "$.detail.bring",
                             healing: "$.detail.phoenix_tears",
                             location: "$.detail.location",
                             urgency: "$.detail.urgency"
                           })
                           .with_attribute_value([:input_transformer, 0, :input_template],
                                                 "{\n  \"detail\": {\n    \"location\": \"<location>\",\n    \"urgency\": \"<about-to-die>\",\n    \"bring\": [\n      <magicItems>\n    ],\n    \"phoenix_tears\": \"<tearsForFears>\"\n  }\n}\n")
      end

      it "specifies gql response" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_explicit')
                           .with_attribute_value(:retry_policy, [{
                                                                   maximum_event_age_in_seconds: 86400,
                                                                   maximum_retry_attempts: 185
                                                                 }])
                           .with_attribute_value([:appsync_target, 0, :graphql_operation],
                                                 "mutation CreateEmergency($input: CreateEmergencyInput!) { createEmergency(input: $input) {\n  message\n  status\n  eta\n}\n}")
      end

      it "creates iam role for target" do
        expect(@plan).to include_resource_creation(type: 'aws_iam_role', module_address: 'module.appsync_explicit').exactly(1).times
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: 'module.appsync_explicit').exactly(1).times
      end

      it "permits only actions required" do
        expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy')
                           .with_attribute_value(:name, "invoke-appsync")
                           .with_attribute_value(:policy, include("appsync:GraphQL"))
                           .with_attribute_value(:policy, include("arn:aws:appsync:us-east-1:123456789012:apis/fawkes-phoenix"))

        # can't currently validate this because the policy is generated based on the ARNs created by
        # other resources
        # .with_attribute_value(:policy, include("events:InvokeApiDestination"))
      end
    end

    context "for passthrough mappings" do
      it "creates for rules targets" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_passthru').once
      end

      it "creates passthrough targets" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_passthru')
                           .with_attribute_value(:rule, "event.SockGiven")
                           .with_attribute_value(:arn, "arn:aws:appsync:us-east-1:123456789012:endpoints/graphql-api/randomstringofcharacters")
                           .with_attribute_value([:input_transformer, 0, :input_paths], {
                             input: "$.detail"
                           })
                           .with_attribute_value([:input_transformer, 0, :input_template], "{ \"input\": <input> }")
      end

      it "specifies gql response" do
        expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target', module_address: 'module.appsync_passthru')
                           .with_attribute_value([:appsync_target, 0, :graphql_operation],
                                                 "mutation FreeDobby($input: FreeDobbyInput!) { freeDobby(input: $input) {\n  message\n  status\n  sockColor\n}\n}")
      end
    end

    it "creates iam role for target" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role', module_address: 'module.appsync_passthru').exactly(1).times
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy', module_address: 'module.appsync_passthru').exactly(1).times
    end

    it "permits only actions required" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy')
                         .with_attribute_value(:name, "invoke-appsync")
                         .with_attribute_value(:policy, include("appsync:GraphQL"))
                         .with_attribute_value(:policy, include("arn:aws:appsync:us-east-1:123456789012:apis/house-elf-dobby"))

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
