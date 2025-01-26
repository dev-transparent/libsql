module Libsql
  class Driver < DB::Driver
    class ConnectionBuilder < ::DB::ConnectionBuilder
      def initialize(@options : ::DB::Connection::Options, @libsql_options : Libsql::Connection::Options)
      end

      def build : ::DB::Connection
        Libsql::Connection.new(@options, @libsql_options)
      end
    end

    def connection_builder(uri : URI) : ::DB::ConnectionBuilder
      params = HTTP::Params.parse(uri.query || "")
      ConnectionBuilder.new(connection_options(params), Libsql::Connection::Options.from_uri(uri))
    end
  end
end

DB.register_driver "libsql", Libsql::Driver