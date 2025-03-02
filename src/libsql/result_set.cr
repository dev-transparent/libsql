module Libsql
  class ResultSet < DB::ResultSet
    @column_index = 0
    @row : LibSQL::Row? = nil

    def initialize(statement : Statement, @rows : LibSQL::Rows)
      super(statement)
    end

    protected def do_close
      LibSQL.libsql_rows_deinit(@rows)
      super
    end

    def move_next : Bool
      @column_index = 0
      @row = Libsql.check LibSQL.libsql_rows_next(@rows)

      !LibSQL.libsql_row_empty(@row.not_nil!)
    end

    def next_column_index : Int32
      @column_index
    end

    def read
      return unless @row

      value = Libsql.check LibSQL.libsql_row_value(@row.not_nil!, @column_index)

      convert(value.ok).tap do
        @column_index += 1
      end
    end

    def read(t : UInt8.class) : UInt8
      read(Int64).to_u8
    end

    def read(type : UInt8?.class) : UInt8?
      read(Int64?).try &.to_u8
    end

    def read(t : UInt16.class) : UInt16
      read(Int64).to_u16
    end

    def read(type : UInt16?.class) : UInt16?
      read(Int64?).try &.to_u16
    end

    def read(t : UInt32.class) : UInt32
      read(Int64).to_u32
    end

    def read(type : UInt32?.class) : UInt32?
      read(Int64?).try &.to_u32
    end

    def read(t : Int8.class) : Int8
      read(Int64).to_i8
    end

    def read(type : Int8?.class) : Int8?
      read(Int64?).try &.to_i8
    end

    def read(t : Int16.class) : Int16
      read(Int64).to_i16
    end

    def read(type : Int16?.class) : Int16?
      read(Int64?).try &.to_i16
    end

    def read(t : Int32.class) : Int32
      read(Int64).to_i32
    end

    def read(type : Int32?.class) : Int32?
      read(Int64?).try &.to_i32
    end

    def read(t : Float32.class) : Float32
      read(Float64).to_f32
    end

    def read(type : Float32?.class) : Float32?
      read(Float64?).try &.to_f32
    end

    def read(t : Time.class) : Time
      text = read(String)
      if text.includes? "."
        Time.parse text, Libsql::DATE_FORMAT_SUBSECOND, location: Libsql::TIME_ZONE
      else
        Time.parse text, Libsql::DATE_FORMAT_SECOND, location: Libsql::TIME_ZONE
      end
    end

    def read(t : Time?.class) : Time?
      read(String?).try { |v|
        if v.includes? "."
          Time.parse v, Libsql::DATE_FORMAT_SUBSECOND, location: SQLite3::TIME_ZONE
        else
          Time.parse v, Libsql::DATE_FORMAT_SECOND, location: SQLite3::TIME_ZONE
        end
      }
    end

    def read(t : Bool.class) : Bool
      read(Int64) != 0
    end

    def read(t : Bool?.class) : Bool?
      read(Int64?).try &.!=(0)
    end

    def column_name(index) : String
      slice = LibSQL.libsql_rows_column_name(@rows, index)

      String.new(slice.ptr, slice.len).tap do
        LibSQL.libsql_slice_deinit(slice)
      end
    end

    def column_count : Int32
      LibSQL.libsql_statement_column_count(self).to_i32
    end

    protected def libsql_statement
      @statement.as(Statement)
    end

    def to_unsafe
      libsql_statement.to_unsafe
    end

    private def convert(value : LibSQL::Value)
      case value.type
      when LibSQL::Type::LIBSQL_TYPE_INTEGER
        value.value.integer
      when LibSQL::Type::LIBSQL_TYPE_REAL
        value.value.real
      when LibSQL::Type::LIBSQL_TYPE_TEXT
        String.new(value.value.text.ptr, value.value.text.len - 1) # Null byte is included in the length
      when LibSQL::Type::LIBSQL_TYPE_BLOB
        Bytes.new(value.value.blob.ptr, value.value.blob.len)
      when LibSQL::Type::LIBSQL_TYPE_NULL
        nil
      end
    end
  end
end