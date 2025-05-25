# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::Replay do
  context "when no data has been persisted" do
    it "returns nothing" do
      expect(described_class.for(type: "A::B::C", id: "12345")).to eq([])
    end
  end

  context "when data has been persisted" do
    it "returns a representation of changes between successive snapshots" do
      Snappier::Registry.persistence.persist(
        type: "A::B::C",
        id: "12345",
        at: "2000000001000",
        args: {
          "who" => "person 1",
          "state" => {
            "content" => "content1"
          }
        },
      )

      Snappier::Registry.persistence.persist(
        type: "A::B::C",
        id: "12345",
        at: "2000000000000",
        args: {
          "state" => {
            "content" => "content2"
          }
        },
      )

      Snappier::Registry.persistence.persist(
        type: "A::B::C",
        id: "12345",
        at: "2000000002000",
        args: {
          "who" => "person 2",
          "state" => {
            "content" => "content3"
          }
        },
      )

      entries = []

      described_class.for(type: "A::B::C", id: "12345") { |entry| entries << entry }

      expect(entries).to(
        eq(
          [
            {
              at: Time.iso8601("2033-05-18T13:33:20+10:00"),
              who: nil,
              changes: { "content" => [nil, "content2"] },
              state: { "content" => "content2" }
            },
            {
              at: Time.iso8601("2033-05-18T13:33:21+10:00"),
              who: "person 1",
              changes: { "content" => %w[content2 content1] },
              state: { "content" => "content1" }
            },
            {
              at: Time.iso8601("2033-05-18T13:33:22+10:00"),
              who: "person 2",
              changes: { "content" => %w[content1 content3] },
              state: { "content" => "content3" }
            }
          ],
        ),
      )
    end
  end
end
