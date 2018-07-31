# sin_refinements

This gem enables Proc level refinements forcibly.

**But it is too slow!!**
**Please don't use in production.**

sin means that this gem uses very sinned way (eval, AST, instance_exec).
And sin (真) means True in Japanese.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sin_refinements'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sin_refinements

## Usage

```ruby
module ExtMod
  refine String do
    def bang
      "#{self}!!"
    end
  end
end

SinRefinements.refining(ExtMod) do
  expect("foo".bang).to eq("foo!!")
end
```

## Performance

### SinRefinements.refining

```
Warming up --------------------------------------
    plain   153.770k i/100ms
 refining    56.000  i/100ms
Calculating -------------------------------------
    plain    2.094M (± 3.3%) 
 refining  560.413  (± 1.2%) 

Comparison:
    plain:  2093833.1 i/s
 refining:      560.4 i/s - 3736.23x  slower
```

---

### SinRefinements.light_refining

This version does not support local variables.

```
Warming up --------------------------------------
    plain   145.078k i/100ms
 refining    18.123k i/100ms
Calculating -------------------------------------
    plain      1.941M (± 3.0)
 refining    189.518k (± 2.6)

Comparison:
    plain:  1941491.1 i/s
 refining:   189518.0 i/s - 10.24x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/sin_refinements.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
