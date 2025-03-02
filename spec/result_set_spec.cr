require "./spec_helper"

private def test_insert_and_read(datatype, value, file = __FILE__, line = __LINE__)
  it "inserts #{datatype}", file, line do
    with_db do |db|
      db.exec("DROP TABLE IF EXISTS test_table")
      db.exec("CREATE TABLE test_table (v #{datatype})")
      db.exec("INSERT INTO test_table values (?)", value)

      actual = db.query_one("SELECT v FROM test_table", as: value.class)
      actual.should eq(value)
    end
  end
end

describe Libsql::ResultSet do
  describe "integer" do
    test_insert_and_read "INTEGER", 123
    test_insert_and_read "INTEGER", -123
  end

  describe "text" do
    test_insert_and_read "VARCHAR(255)", "hello world"
    test_insert_and_read "TEXT", "hello world"
  end

  describe "real" do
    test_insert_and_read "REAL", 2346.45645
    test_insert_and_read "DOUBLE", 2346.45645
    test_insert_and_read "FLOAT", 2346.45645
  end

  describe "boolean" do
    test_insert_and_read "BOOLEAN", true
    test_insert_and_read "BOOLEAN", false
  end
end