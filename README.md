# JsonApiResource

JsonApiResource is an abstraction layer that sits on top of [JsonApiClient](https://github.com/chingor13/json_api_client) that lets the user interact with client objects the way they would with an ActiveRecord model. It provides objectification of attributes, population with defaults, metadata and error handling on server requests. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_resource'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_api_resource

## Usage

### Example

Let's say you have a JsonApi server Account, which has a RESTful controller, `UsersController` and you have a `JsonApiClient` that can talk to it. And you would like to interact with the server result as an object, rather than

```ruby
  user = Account::Client::User.find(15)
  user["name"]
```

You can wrap it in a `JsonApiResource`

```ruby
module Account
  class User < JsonApiResource::Resource

    # define what your client is
    wraps Account::Client::User

    # define what fields you expect, with defaults, should you create a new object
    #   or should the server omit fields in its response
    properties   id: nil,
               name: "",
        permissions: [],
         friend_ids: []

    # your custom code here
    def friends
      @friends ||= where(id: friend_ids)
    end

    #etc
  end
end
```

Then you can interface with the `Account::User` class, as you would any old AR class.

```ruby

  # find works the way you would expect
  john = Account::User.find(38)
  john.name = "Johnny"

  # will make a PUT call to the server
  john.save # => true

  # if you preforma an action that fails validation
  john.name = ""
  john.save  # => false

  john.errors # ActiveModel::Errors errors that you can nicely pipe into your forms

  mark = Account::User.new
  mark.id # => nil

  mark.name = "Mark"

  mark.save # => true

  # etc
```

### Keywords

#### wraps

`wraps` is an interface method that defines what `JsonApiClient` class the resource will wrap and connect to.

```ruby
module Account
  class User < JsonApiResource::Resource

    wraps Account::Client::User

  end
end
```

#### property

Define a single property that will be populated on new object or if the field is missing.

```ruby
class User < JsonApiResource::Resource
  wraps Whatever 

  # defaults to nil
  property :id

  # defaults to ""
  property :name, ""
end

```

#### properties

Define multiple properties

```ruby
class User < JsonApiResource::Resource
  wraps Whatever 

  properties id: nil,
           name: ""
end
```

NOTE: all properties are optional. If you don't have it defined and it's in the payload, it will still be part of your resulting object. For example, if you define no properties, but your payload comes in as

```json
{  
           "id": 10,
         "name": "john",
  "permissions": []
}
```

The object will still reply to `id`, `name` and `permissions`, but you won't be able to assume they are there, and they will not appear when you do `ResourceClass.new`.

### Other Features

#### Caching

JsonApiResource does a full digest of the json blob, so if your server schema changes, you will see your client side cache burst.

#### Error handling

As seen in the example above, JsonApiResource extracts the server errors from the metadata and wraps them nicely in `ActiveModel::Errors`, for easy form integration.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avvo/json_api_resource.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
