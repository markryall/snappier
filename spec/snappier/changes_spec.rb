# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::Changes do
  it "finds no change between identical hashes" do
    changes = described_class.between(
      { "attribute1" => "value1" },
      { "attribute1" => "value1" },
    )

    expect(changes).to eq({})
  end

  it "finds change when value is changed" do
    changes = described_class.between(
      { "attribute1" => "value1" },
      { "attribute1" => "value2" },
    )

    expect(changes).to eq({ %w[attribute1] => %w[value1 value2] })
  end

  it "finds change when key is removed" do
    changes = described_class.between(
      { "attribute" => "value" },
      {},
    )

    expect(changes).to eq({ %w[attribute] => ["value", nil] })
  end

  it "finds change when key is added" do
    changes = described_class.between(
      {},
      { "attribute" => "value" },
    )

    expect(changes).to eq({ %w[attribute] => [nil, "value"] })
  end

  it "finds change when nested key is changed" do
    changes = described_class.between(
      { "hash" => { "attribute" => "value1" } },
      { "hash" => { "attribute" => "value2" } },
    )

    expect(changes).to eq({ %w[hash attribute] => %w[value1 value2] })
  end

  it "finds change when nested key is removed" do
    changes = described_class.between(
      { "hash" => { "attribute" => "value" } },
      { "hash" => {} },
    )

    expect(changes).to eq({ %w[hash attribute] => ["value", nil] })
  end

  it "finds change when nested key is added" do
    changes = described_class.between(
      { "hash" => {} },
      { "hash" => { "attribute" => "value" } },
    )

    expect(changes).to eq({ %w[hash attribute] => [nil, "value"] })
  end

  it "finds change when association is changed" do
    changes = described_class.between(
      { "hash" => { "id" => "123", "attribute" => "value1" } },
      { "hash" => { "id" => "123", "attribute" => "value2" } },
    )

    expect(changes).to eq({ %w[hash 123 attribute] => %w[value1 value2] })
  end

  it "finds change when association is removed" do
    changes = described_class.between(
      { "hash" => { "id" => "123", "attribute" => "value" } },
      { "hash" => {} },
    )

    expect(changes).to eq({ %w[hash 123 attribute] => ["value", nil] })
  end

  it "finds change when association is added" do
    changes = described_class.between(
      { "hash" => {} },
      { "hash" => { "id" => "123", "attribute" => "value" } },
    )

    expect(changes).to eq({ %w[hash 123 attribute] => [nil, "value"] })
  end

  it "finds change when association is replaced" do
    changes = described_class.between(
      { "hash" => { "id" => "123", "attribute" => "value" } },
      { "hash" => { "id" => "321", "attribute" => "value" } },
    )

    expect(changes).to(
      eq(
        {
          %w[hash 123 attribute] => ["value", nil],
          %w[hash 321 attribute] => [nil, "value"]
        },
      ),
    )
  end

  it "finds change when element in collection is changed" do
    changes = described_class.between(
      { "hash" => [{ "id" => "123", "attribute" => "value1" }] },
      { "hash" => [{ "id" => "123", "attribute" => "value2" }] },
    )

    expect(changes).to eq({ %w[hash 123 attribute] => %w[value1 value2] })
  end
end
