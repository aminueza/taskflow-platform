# frozen_string_literal: true

# Code coverage
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/vendor/'

    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Services', 'app/services'
    add_group 'Workers', 'app/workers'

    minimum_coverage 80
    minimum_coverage_by_file 70
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Use documentation format for better output
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Run specs in random order
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Focus on specific tests with :focus tag
  config.filter_run_when_matching :focus

  # Profile slow tests
  config.profile_examples = 10
end
