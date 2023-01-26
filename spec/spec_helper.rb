require 'rspec/terraform'

RSpec.configure do |config|
  config.terraform_log_level = :warn
  config.terraform_stdout = Logger::LogDevice.new(IO::NULL) if ENV.fetch('SILENCE_TERRAFORM', "true") == "true"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
