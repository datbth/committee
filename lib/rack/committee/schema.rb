module Rack::Committee
  class Schema
    include Enumerable

    def initialize(data)
      @schema = MultiJson.decode(data)
      manifest_regex
    end

    def [](type)
      @schema["definitions"][type]
    end

    def each
      @schema["definitions"].each do |type, type_schema|
        yield(type, type_schema)
      end
    end

    def find(ref)
      parts = ref.split("/")
      parts.shift if parts.first == "#"
      pointer = @schema
      parts.each { |p|
        next unless pointer
        pointer = pointer[p]
      }
      raise ReferenceNotFound, "Reference not found: #{ref}." if !pointer
      pointer
    end

    private

    def manifest_regex
      @schema["definitions"].each do |_, type_schema|
        type_schema["definitions"].each do |_, property_schema|
          if pattern = property_schema["pattern"]
            property_schema["pattern"] = Regexp.new(pattern)
          end
        end
      end
    end
  end
end
