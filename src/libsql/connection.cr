module Libsql
  class Connection < DB::Connection
    record Options,
      url : String? = nil,
      path : String? = nil,
      auth_token : String? = nil,
      encryption_key : String? = nil,
      sync_interval : UInt64? = nil do
      def self.from_uri(uri : URI, default = Options.new)
        params = HTTP::Params.parse(uri.query || "")

        scheme = uri.scheme == "libsql" ? "http" : "https"

        Options.new(
          url: "#{scheme}://#{uri.host}:#{uri.port}",
          path: params.fetch("path", default.path),
          auth_token: params.fetch("auth_token", default.auth_token),
          encryption_key: params.fetch("encryption_key", default.encryption_key),
          sync_interval: params.fetch("sync_interval", default.sync_interval).try &.to_u64,
        )
      end
    end

    @desc : LibSQL::DatabaseDesc
    @db : LibSQL::Database
    @conn : LibSQL::Connection

    def initialize(options : ::DB::Connection::Options, libsql_options : Options)
      super(options)

      @desc = LibSQL::DatabaseDesc.new

      if url = libsql_options.url
        @desc.url = url
      end

      if path = libsql_options.path
        @desc.path = path
      end

      if auth_token = libsql_options.auth_token
        @desc.auth_token = auth_token
      end

      if encryption_key = libsql_options.encryption_key
        @desc.encryption_key = encryption_key
      end

      if sync_interval = libsql_options.sync_interval
        @desc.sync_interval = sync_interval
      end

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