module Libsql
  class Connection < DB::Connection
    record Options,
      url : String? = nil,
      auth_token : String? = nil do
      def self.from_uri(uri : URI, default = Options.new)
        params = HTTP::Params.parse(uri.query || "")

        Options.new(
          url: "#{uri.scheme}://#{uri.host}",
          auth_token: params.fetch("auth_token", default.auth_token)
        )
      end
    end

    @desc : LibSQL::DatabaseDesc
    @db : LibSQL::Database
    @conn : LibSQL::Connection

    def initialize(options : ::DB::Connection::Options, libsql_options : Options)
      super(options)

      @desc = LibSQL::DatabaseDesc.new
      @desc.url = libsql_options.url.not_nil!
      @desc.auth_token = libsql_options.auth_token.not_nil!

      @db = Libsql.check LibSQL.libsql_database_init(@desc)
      @conn = Libsql.check LibSQL.libsql_database_connect(@db)
    end

    def build_prepared_statement(query) : Statement
      Statement.new(self, query)
    end

    def build_unprepared_statement(query) : Statement
      raise DB::Error.new("Libsql driver does not support unprepared statements")
    end

    def do_close
      super

      LibSQL.libsql_connection_deinit(@conn)
      LibSQL.libsql_database_deinit(@db)
    end

    # :nodoc:
    def perform_begin_transaction
      self.prepared.exec "BEGIN"
    end

    # :nodoc:
    def perform_commit_transaction
      self.prepared.exec "COMMIT"
    end

    # :nodoc:
    def perform_rollback_transaction
      self.prepared.exec "ROLLBACK"
    end

    # :nodoc:
    def perform_create_savepoint(name)
      self.prepared.exec "SAVEPOINT #{name}"
    end

    # :nodoc:
    def perform_release_savepoint(name)
      self.prepared.exec "RELEASE SAVEPOINT #{name}"
    end

    # :nodoc:
    def perform_rollback_savepoint(name)
      self.prepared.exec "ROLLBACK TO #{name}"
    end

    def to_unsafe
      @conn
    end
  end
end