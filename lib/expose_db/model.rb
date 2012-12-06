require 'hashie'
require 'httparty'
require 'expose_db/model/querying'
require 'expose_db/model/relations'

module ExposeDB
  class RecordNotFound < StandardError; end

  class Model < Hashie::Mash
    include HTTParty
    extend ExposeDB::Querying
    extend ExposeDB::Relations

    def self.exposed_as(new_exposed_as = nil)
      return @exposed_as unless new_exposed_as
      @exposed_as = new_exposed_as.to_s
    end
  end
end
