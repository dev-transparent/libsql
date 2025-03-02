module Libsql
  class Statement < DB::Statement
    @statement : LibSQL::Statement

    def initialize(connection, command)
      super(connection, command)

      @statement = Libsql.check LibSQL.libsql_connection_prepare(conn, command)
    end

    private def conn
      connection.as(Libsql::Connection)
    end

    protected def perform_query(args : Enumerable) : DB::ResultSet
      bind_args(args)

      result = Libsql.check LibSQL.libsql_statement_query(self)

      ResultSet.new(self, result)
    end

    protected def perform_exec(args : Enumerable) : DB::ExecResult
      bind_args(args)

      result = Libsql.check LibSQL.libsql_statement_execute(self)
      info = Libsql.check LibSQL.libsql_connection_info(conn)

      DB::ExecResult.new result.rows_changed.to_i64, info.last_inserted_rowid
    end

    private def bind_args(args : Enumerable)
      args.each do |arg|
        if arg.is_a?(Hash)
          arg.each do |name, arg|
            Libsql.check LibSQL.libsql_statement_bind_named(self, name, convert(arg))
          end
        else
          Libsql.check LibSQL.libsql_statement_bind_value(self, convert(arg))
        end
      end
    end

    private def convert(arg) : LibSQL::Value
      case arg
      when Int
        LibSQL.libsql_integer(arg.to_i64)
      when Float
        LibSQL.libsql_real(arg.to_f64)
      when String
        LibSQL.libsql_text(arg, arg.bytesize)
      when Bytes
        LibSQL.libsql_blob(arg, arg.size)
      when Nil
        LibSQL.libsql_null
      else
        raise "Unsupported value type: #{arg.class.name}"
      end
    end

    protected def do_close
      super

      # TODO: Deinit doesn't work?
      # LibSQL.libsql_statement_deinit(@statement)
    end

    def to_unsafe
      @statement
    end
  end
end