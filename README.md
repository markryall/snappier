# Snappier

Imagine a dream where every moment your objects whisper their truths into the ether—each change a shimmer in time, gently bottled and sealed. Snappier is the archivist of that dream: a watchful spirit that captures the essence of Ruby objects, encasing their state in crystalline snapshots. Through enchanted serializers and portals like S3, their stories are preserved across realms. You shape the ritual—what is seen, how it's told, where it rests—yet Snappier hums quietly, faithfully, beneath it all.

## Installation

```bash
bundle add snappier
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install snappier
```

## Usage

Call `Snappier::Take.for(entity)` in your application code and a snapshopt will be persisted via a
sidekiq job (this specific dependency on sidekiq for async processing may be abstracted later).

You may call this in an active record model callback (like `after_save`) or anywhere else in your application code.

There is no specific dependency on active record but the methods `attributes`, `previously_new_record?` and
`destroyed?` are used by default (the latter two deciding if snapshot is related to create/delete otherwise
defaulting to update).

To attribute changes to a specific user, call `Snappier::Who.current = "<current user description>"` and that
information will be persisted with any subsequent snapshots.  In rails, you may set this in a `before_action`
method to capture a description of the current user - this setting exists only in the current thread.

By default snapshots are persisted to `tmp/snappier`.  You can instead persist to S3 using the `snappier-aws_s3`
extension gem and the following configuration when your application starts up:

```ruby
persistence = Snappier::AwsS3::Persistence.new(
  region: aws_region,
  bucket_name: bucket_name,
  credentials: aws_credentials,
)
Snappier::Registry.register_persistence(persistence)
```

By default, snapshot state is persisted by calling `record.attributes`, if you want to persist more or less
information then you can create a module and register it when your application starts up:

```ruby
module OrderSnapshot
  def self.snap(order)
    order.attributes.without(:created_at, :updated_at).tap do |attributes|
      attributes["line_items"] = order.line_items.map { |line_item| line_item.attributes }
    end
  end
end

Snappier::Registry.register(
  "Order" => "OrderSnapshot"
)
```

It is possible to replay the snapshots for a specific record which will calculate any change for presentation
in a UI:

```ruby
Snappier::Replay.for(
  type: Order,
  id: "1"
) { |change| pp change }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/markryall/snappier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/markryall/snappier/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Snappier project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/markryall/snappier/blob/main/CODE_OF_CONDUCT.md).
