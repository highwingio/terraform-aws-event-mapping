require 'spec_helper'

RSpec.describe "event api targets" do
  before :all do
    @plan = plan(configuration_directory: 'examples/event_api_targets')
  end

  context "aws_cloudwatch_event_rules" do
    it "creates for bus targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_rule').once
    end
  end

  context "aws_cloudwatch_event_target" do
    it "creates for rules targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target').twice
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_target')
                         .with_attribute_value(:rule, "event.HogwartsExternal")
                         .with_attribute_value([:input_transformer, 0, :input_paths], { submission_uuid: "$.detail.student_name" })
                         .with_attribute_value([:input_transformer, 0, :input_template], JSON.pretty_generate({
                           blocks: [
                             {
                               type: "section",
                               text: {
                                 type: "mrkdwn",
                                 text: "Under-aged student *<student_name>* has conjured an unauthorized spell."
                               }
                             }
                           ]
                         }))
    end
  end

  context "aws_cloudwatch_event_api_destination" do
    it "creates for rules targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_api_destination').twice
    end

    it "specifies destinations" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_api_destination')
                         .with_attribute_value(:name, "event.HogwartsExternal-slack")
                         .with_attribute_value(:invocation_endpoint, "https://hooks.slack.com/services/my/random/key")
                         .with_attribute_value(:http_method, "POST")
    end
  end

  context "aws_cloudwatch_event_connection" do
    it "creates event connection" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_connection').twice
    end

    it "specifies targets" do
      expect(@plan).to include_resource_creation(type: 'aws_cloudwatch_event_connection')
                         .with_attribute_value(:name, "event.HogwartsExternal-slack")
                         .with_attribute_value(:authorization_type, "API_KEY")
      # .with_attribute_value([:auth_parameters, 0, :api_key, 0], { key: "Authorization", value: "Bearer xoxb-rando-tokenizer" })
    end
  end


  context "aws_iam_role" do
    it "creates iam role for target" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role').exactly(1).times
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy').exactly(1).times
    end

    it "permits only actions required" do
      expect(@plan).to include_resource_creation(type: 'aws_iam_role_policy')
                         .with_attribute_value(:name, "invoke-api")

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
