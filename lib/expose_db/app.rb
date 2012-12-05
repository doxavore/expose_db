module ExposeDB
  class App < Sinatra::Base
    enable :logging

    class << self
      attr_reader :db

      def run!(sequel_db, *args)
        @db = sequel_db
        super(*args)
      end
    end

    not_found do
      "Unable to find that table or record."
    end

    error do
      "ERROR: An unhandled error occurred. Check the logs."
    end

    helpers do
      def db
        self.class.db
      end

      def ensure_table_exists!
        raise Sinatra::NotFound unless db.table_exists?(table_name)
      end

      def table_name
        @table_name ||= params[:table].to_sym
      end

      def json(obj)
        MultiJson.dump obj
      end
    end

    get '/' do
      erb :index
    end

    get '/:table' do
      ensure_table_exists!

      query = params[:q]
      values = params[:values] || []
      dataset = db[table_name]

      if query && query.length > 0
        dataset = dataset.filter(query, *values)
      end

      json dataset.to_a
    end

    get '/:table/:id' do
      ensure_table_exists!

      id = params[:id]
      dataset = db[table_name]

      json dataset[id: id]
    end
  end
end
