# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::Take do
  before do
    @entity = double(
      "entity",
      id: "12345",
      # class: double("entity class", name: "Entity::Class"),
      previously_new_record?: false,
      destroyed?: false,
      attributes: {
        attribute1: "value1",
        attribute2: "value2"
      },
    )
    allow(@entity).to receive(:class).and_return(double("entity class", name: "A::B::C"))
  end

  it "persists changes to an entity" do
    described_class.for(@entity)

    jobs = Sidekiq::Job.jobs
    expect(jobs.count).to eq(1)

    job = jobs.first
    expect(job["class"]).to eq("Snappier::Job")

    args = job["args"].first
    expect(args["action"]).to eq("update")
    expect(args["id"]).to eq("12345")
    expect(args["who"]).to be_nil
    expect(args["type"]).to eq("A::B::C")
    expect(JSON.parse(args["state"])).to(
      eq(
        "attribute1" => "value1",
        "attribute2" => "value2",
      ),
    )
  end

  context "with registered class for snapshots" do
    it "persists changes to an entity using registered class" do
      Snappier::Registry.register(
        "A::B::C" => "Snappier::Testing::Entity",
      )

      described_class.for(@entity)

      jobs = Sidekiq::Job.jobs
      job = jobs.first
      args = job["args"].first
      expect(JSON.parse(args["state"])).to(
        eq(
          "attribute1" => "value1",
        ),
      )
    end
  end

  context "with Who.current assigned" do
    it "persists changes to an entity with who" do
      Snappier::Who.current = "the current user"

      described_class.for(@entity)

      jobs = Sidekiq::Job.jobs
      job = jobs.first
      args = job["args"].first
      expect(args["who"]).to eq("the current user")
    end
  end
end
