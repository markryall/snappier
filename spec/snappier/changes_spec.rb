# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::Changes do
  it "finds no change between nil and nil" do
    changes = described_class.between(nil, nil)

    expect(changes).to eq({})
  end

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

  it "finds no change when array is unchanged" do
    changes = described_class.between(
      { "attribute1" => ["value"] },
      { "attribute1" => ["value"] },
    )

    expect(changes).to eq({})
  end

  it "finds change when array is changed" do
    changes = described_class.between(
      { "attribute1" => ["value1"] },
      { "attribute1" => ["value2"] },
    )

    expect(changes).to eq({ %w[attribute1] => [%w[value1], %w[value2]] })
  end

  it "finds change when array is added" do
    changes = described_class.between(
      {},
      { "attribute1" => ["value1"] },
    )

    expect(changes).to eq({ %w[attribute1] => [nil, %w[value1]] })
  end

  it "finds change when array is removed" do
    changes = described_class.between(
      { "attribute1" => ["value1"] },
      {},
    )

    expect(changes).to eq({ %w[attribute1] => [%w[value1], nil] })
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

  it "finds no change when association is unchanged" do
    changes = described_class.between(
      { "hash" => { "id" => "123", "attribute" => "value" } },
      { "hash" => { "id" => "123", "attribute" => "value" } },
    )

    expect(changes).to eq({})
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

  it "finds no change when no element in collection is changed" do
    changes = described_class.between(
      { "collection" => [{ "id" => "123", "attribute" => "value" }] },
      { "collection" => [{ "id" => "123", "attribute" => "value" }] },
    )

    expect(changes).to eq({})
  end

  it "finds change when element in collection is changed" do
    changes = described_class.between(
      { "collection" => [{ "id" => "123", "attribute" => "value1" }] },
      { "collection" => [{ "id" => "123", "attribute" => "value2" }] },
    )

    expect(changes).to eq({ %w[collection 123 attribute] => %w[value1 value2] })
  end

  it "finds change when element in collection is added" do
    changes = described_class.between(
      { "collection" => [] },
      { "collection" => [{ "id" => "123", "attribute1" => "value1", "attribute2" => "value2" }] },
    )

    expect(changes).to(
      eq(
        %w[collection 123 attribute1] => [nil, "value1"],
        %w[collection 123 attribute2] => [nil, "value2"],
      ),
    )
  end

  it "finds change when element in collection is removed" do
    changes = described_class.between(
      { "collection" => [{ "id" => "123", "attribute1" => "value1", "attribute2" => "value2" }] },
      { "collection" => [] },
    )

    expect(changes).to(
      eq(
        %w[collection 123 attribute1] => ["value1", nil],
        %w[collection 123 attribute2] => ["value2", nil],
      ),
    )
  end

  it "finds all changes in complicated structure" do
    changes = described_class.between(
      {
        "attribute" => "value1",
        "array" => ["array_value1"],
        "collection" => [
          {
            "id" => "123",
            "nested_collection" => [
              {
                "id" => "456",
                "nested_attribute" => "nested_value1"
              }
            ],
            "attribute" => "value1"
          }
        ]
      },
      {
        "attribute" => "value2",
        "array" => ["array_value2"],
        "collection" => [
          {
            "id" => "123",
            "nested_collection" => [
              {
                "id" => "456",
                "nested_attribute" => "nested_value2"
              }
            ],
            "attribute" => "value2"
          }
        ]
      },
    )

    expect(changes).to(
      eq(
        %w[array] => [%w[array_value1], %w[array_value2]],
        %w[attribute] => %w[value1 value2],
        %w[collection 123 attribute] => %w[value1 value2],
        %w[collection 123 nested_collection 456 nested_attribute] => %w[nested_value1 nested_value2],
      ),
    )
  end
end
