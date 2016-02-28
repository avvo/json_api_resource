module JsonApiResource
  class ResultSet < JsonApiClient::ResultSet
    include JsonApiResource::Fallbackable

    def self.build(client_set = JsonApiClient::ResultSet.new)
      set = self.new

      set.total_pages   = client_set.total_pages
      set.total_entries = client_set.total_entries
      set.offset        = client_set.offset
      set.per_page      = client_set.per_page
      set.current_page  = client_set.current_page
      set.errors        = client_set.errors
      set.record_class  = client_set.record_class
      set.meta          = client_set.meta

      set
    end
  end
end