# JsonApiResource

Common code wrapper object or Adapter class to extend a JsonApiClient::Resource

## Usage

### Basic

```
class Customer < JsonApiResource::Resource
  property :name => 'name', :email => '', :permissions => []
  api_client Ledger::Client::Customer
end

item = Customer.new
#<Customer:0x007f84b7a72568 @client=#<Ledger::Client::Customer:0x007f84b7a71398 @attributes={"id"=>nil, "name"=>"name", "email"=>"", "permissions"=>[]}>>

