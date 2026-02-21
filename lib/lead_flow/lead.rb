module LeadFlow
  # Every connector transforms platform-specific data into this format.
  Lead = Struct.new(
    :source,      # String
    :external_id, # String (unique ID from platform)
    :author,      # String
    :title,       # String
    :content,     # String
    :url,         # String
    :metadata,    # Hash (optional, platform-specific)
    :captured_at, # Time object
    keyword_init: true
  )
end
