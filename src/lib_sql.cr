{% if flag?(:darwin) %}
  @[Link(ldflags: "#{__DIR__}/../.target/release/liblibsql.dylib")]
{% else %}
  @[Link(ldflags: "#{__DIR__}/../.target/release/liblibsql.so")]
{% end %}
lib LibSQL
  enum Cypher
    LIBSQL_CYPHER_DEFAULT
    LIBSQL_CYPHER_AES256
  end

  enum Type
    LIBSQL_TYPE_INTEGER = 1
    LIBSQL_TYPE_REAL = 2
    LIBSQL_TYPE_TEXT = 3
    LIBSQL_TYPE_BLOB = 4
    LIBSQL_TYPE_NULL = 5
  end

  enum TracingLevel
    LIBSQL_TRACING_LEVEL_ERROR = 1
    LIBSQL_TRACING_LEVEL_WARN
    LIBSQL_TRACING_LEVEL_INFO
    LIBSQL_TRACING_LEVEL_DEBUG
    LIBSQL_TRACING_LEVEL_TRACE
  end

  type Error = Void*

  struct Log
    message : LibC::Char*
    target : LibC::Char*
    file : LibC::Char*
    timestamp : UInt64
    line : LibC::SizeT
    level : TracingLevel
  end

  struct Database
    err : Error*
    inner : Void*
  end

  struct Connection
    err : Error*
    inner : Void*
  end

  struct Statement
    err : Error*
    inner : Void*
  end

  struct Transaction
    err : Error*
    inner : Void*
  end

  struct Rows
    err : Error*
    inner : Void*
  end

  struct Row
    err : Error*
    inner : Void*
  end

  struct Batch
    err : Error*
  end

  struct Slice
    ptr : UInt8*
    len : LibC::SizeT
  end

  union ValueUnion
    integer : Int64
    real : Float64
    text : Slice
    blob : Slice
  end

  struct Value
    value : ValueUnion
    type : Type
  end

  struct ResultValue
    err : Error*
    ok : Value
  end

  struct Sync
    err : Error*
    frame_no : UInt64
    frame_synced : UInt64
  end

  struct Bind
    err : Error*
  end

  struct Execute
    err : Error*
    rows_changed : UInt64
  end

  struct ConnectionInfo
    err : Error*
    last_inserted_rowid : Int64
    total_changes : UInt64
  end

  struct DatabaseDesc
    url : LibC::Char*
    path : LibC::Char*
    auth_token : LibC::Char*
    encryption_key : LibC::Char*
    sync_interval : UInt64
    cypher : Cypher
    disable_read_your_writes : Bool
    webpki : Bool
    synced : Bool
    disable_safety_assert : Bool
  end

  struct Config
    logger : Log -> Void
    version : LibC::Char*
  end

  fun libsql_setup(config : Config) : Error*
  fun libsql_error_message(error : Error*) : LibC::Char*
  fun libsql_database_init(desc : DatabaseDesc) : Database
  fun libsql_database_sync(database : Database) : Sync
  fun libsql_database_connect(database : Database) : Connection
  fun libsql_connection_transaction(connection : Connection) : Transaction
  fun libsql_connection_batch(connection : Connection, sql : LibC::Char*) : Batch
  fun libsql_connection_info(connection : Connection) : ConnectionInfo
  fun libsql_transaction_batch(transaction : Transaction, sql : LibC::Char*) : Batch
  fun libsql_connection_prepare(connection : Connection, sql : LibC::Char*) : Statement
  fun libsql_transaction_prepare(transaction : Transaction, sql : LibC::Char*) : Statement
  fun libsql_statement_execute(statement : Statement) : Execute
  fun libsql_statement_query(statement : Statement) : Rows
  fun libsql_statement_reset(statement : Statement) : Void
  fun libsql_statement_column_count(statement : Statement) : LibC::SizeT

  fun libsql_rows_next(rows : Rows) : Row
  fun libsql_rows_column_name(rows : Rows, index : Int32) : Slice
  fun libsql_rows_column_count(rows : Rows) : Int32

  fun libsql_row_value(row : Row, index : Int32) : ResultValue
  fun libsql_row_name(row : Row, index : Int32) : Slice
  fun libsql_row_length(row : Row) : Int32
  fun libsql_row_empty(row : Row) : Bool

  fun libsql_statement_bind_named(statement : Statement, name : LibC::Char*, value : Value) : Bind
  fun libsql_statement_bind_value(statement : Statement, value : Value) : Bind

  fun libsql_integer(integer : Int64) : Value
  fun libsql_real(real : Float64) : Value
  fun libsql_text(ptr : LibC::Char*, len : LibC::SizeT) : Value
  fun libsql_blob(ptr : UInt8*, len : LibC::SizeT) : Value
  fun libsql_null : Value

  fun libsql_error_deinit(error : Error*) : Void
  fun libsql_database_deinit(database : Database) : Void
  fun libsql_connection_deinit(connection : Connection) : Void
  fun libsql_statement_deinit(statement : Statement) : Void
  fun libsql_transaction_commit(transaction : Transaction) : Void
  fun libsql_transaction_rollback(transaction : Transaction) : Void
  fun libsql_rows_deinit(rows : Rows) : Void
  fun libsql_row_deinit(row : Row) : Void
  fun libsql_slice_deinit(value : Slice) : Void
end
