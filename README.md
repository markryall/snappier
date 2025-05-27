# Snappier

Snappier is a gem intended to provide a data audit trail by persisting snapshots. This functionality is particularly useful for applications that require tracking changes to data over time, such as for auditing, debugging, or maintaining historical records.

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
sidekiq job.

You may call this in an active record model callback (like `after_save`) or anywhere else in your application code.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/markryall/snappier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/markryall/snappier/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Snappier project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/markryall/snappier/blob/main/CODE_OF_CONDUCT.md).
