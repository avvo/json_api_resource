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

### Associations

#### interface

* `belongs_to` - your resource has the `#{object}_id` for the association.
  * calls `object_class.find `
* `has_one` - will call the server with `opts.merge "#{root_class}_id => root_object.id` and grab the first thing that comes back
  * calls `object_class.where`
* `has_many` - same as `has_one` but will give you the full array of objects
  * calls 'object_class.where`

#### options

* `:foreign_key` - this is what the server will get as the key for `has_one` and `has_many`. `belongs_to` is weird and will send the key to the resource object. for example
```ruby
class Admin < JsonApiResource::Resource
  wraps Service::Client::Admin

  property user_id
  # this one is a little weird
  belongs_to :person, foreign_key: :user_id, class: User
end
```
* `:action` - If you have a custom action you're using for lookup, you can override the default `where` and `find`. For example
```ruby
class Service::Client::Superuser < Service::Client::Base
  # i don't know why you would have this, but whatever
  custom_endpoint :superuser_from_user_id, :on=> :collection, :request_method=> :get
end

* 'class' - specifies the class for the association
* 'class_name' - a string that specifies a class for the association. Handy for load order issues

class User
  wraps Service::Client::User
  has_one :superuser, action: :superuser_from_user_id
end
```
*NOTE: keep in mind, this will still make the call with the `opts.merge foreign_key => root_object.id` hash. If you want to override the query, you may want to consider 1: if the API is RESTful 2: rolling your own association.*

* `:prefetched_ids` *(`has_many` only)* -  in the case that the root object has a collection of ids that come preloaded in it
```ruby
class User < JsonApiResource::Resource
  wraps Service::Client::User
  property address_ids, []

  has_many :addresses, prefetched_ids: :address_ids
end
```


#### notes
* `:through` is not supported, nor will it ever be, because of the hidden complexity and cost of n HTTP calls. if you want to implement `through` do

* the servers you're preloading from/associating have controller entities that respond to show(`find`) and index(`where`)
* __important__: the index(`where`) action has to support `ingore_pagination`. Otherwise you may lose associations as they get capped by the per-page limit

### Preloader

Sometimes you have many objects that you need to fetch associations for. It's expensive to have to iterate over them one by one and annoying to have to assign the results. Well, now there's a `Preloader` that can do all of that for you

#### example

Let's say you have `user`s who have `address`es. 
```ruby
class User < JsonApiResource::Resource
  wraps Service::Client::User

  # shiny new function yay
  has_many :addresses
end

class Address < JsonApiResource::Resource
  wraps Service::Client::Address
end
```

With the associations in place, you can now use them to preload all the addresses for your users in a single query.

```ruby
@users = User.where id: [1, 2, 3, 4, 5]

# that's it. that's all you have to do.
JsonApiClient::Associations::Preloader.preload @users, :addresses

# all the users now have addresses assigned to them and will not hit the server again
puts @users.map &:addresses
```

#### interface

`Preloader.preload( objects, preloads )` takes

* the objects you want the associations to be tied to (`@users` in our example)
* the list of associations you want bulk fetched from the server as symbols. 
  * can be a single symbol, or a list
  * has to have a corresponding association on the objects, and the name has to match

#### notes

This is a simple tool so don't expect too much magic. The Preloader will explode if

* the objects aren't the same class
* the results aren't the same class (although i don't know how that would be possible)
* the result set can't be matched to the objects

### Error Handling

On an unsuccessful call to the server (this means that if you have multiple connections, they will *necessarily* **all** have to fail), errors will be routed through an overridable `handle_failed_request(e)` method. By default it will re-raise the error, but you can handle it any way you want. 

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
