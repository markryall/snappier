# frozen_string_literal: true

require "sidekiq/testing"
require "snappier"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    FileUtils.rm_rf("tmp/snappier")
    Sidekiq::Job.clear_all
    Snappier::Registry.reset
  end
end

# Some classes used in specs

module Snappier
  module Testing
    module Entity
      def self.snap(entity)
        entity.attributes.slice(:attribute1)
      end
    end
  end
end
