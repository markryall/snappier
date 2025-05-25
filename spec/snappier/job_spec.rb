# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::Job do
  it "writes to a file when job is executed" do
    described_class.new.perform(
      "type" => "A::B::C",
      "id" => "12345",
      "at" => "2000000000000",
      "state" => {
        attribute1: "value1",
        attribute2: "value2"
      }.to_json,
    )

    content = YAML.load_file("tmp/snappier/A::B::C/12345/2000000000000.yml")

    expect(content).to(
      eq(
        "type" => "A::B::C",
        "id" => "12345",
        "at" => "2033-05-18 13:33:20 +1000",
        "state" => { "attribute1" => "value1", "attribute2" => "value2" },
      ),
    )
  end
end
