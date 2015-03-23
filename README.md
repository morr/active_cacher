# ActiveCacher

[![RubyGems][gem_version_badge]][ruby_gems]
[![Travis CI][travis_ci_badge]][travis_ci]
[![Code Climate][code_climate_badge]][code_climate]
[![Code Climate Coverage][code_climate_coverage_badge]][code_climate]
[![RubyGems][gem_downloads_badge]][ruby_gems]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_cacher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_cacher

## Usage

Module for caching results of method invocations. It's used as follows:

```ruby
class A
  prepend ActiveCacher.instance
  instance_cache :foo_a, :foo_b
  rails_cache :foo_c

   def foo_a
     # some code
   end
   def foo_b
     # some code
   end
   def foo_c
     # some code
   end
end
```

Here return values of method calls `foo_a` and `foo_b` will be cached into
instance variables `@_foo_a` and `@__foo_b` while result of method call `foo_c`
will be both cached into instance variable `@_foo_c` and written to Rails cache.

Calling `instance_cache :foo_a` is roughly equivalent to the following code:

```ruby
def foo_a
  @__foo_a ||= begin
    # some code
  end
end
```

And calling `rails_cache :foo_c` is roughly equivalent to the following code:

```ruby
def foo_c
  @__foo_c ||= Rails.cache.fetch [self, :foo_c] do
    # some code
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_cacher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
