require "spec"
require "../src/libsql"

def with_db(&block : DB::Database ->)
  DB.open "libsql://0.0.0.0:8080?auth_token=fake", &block
end