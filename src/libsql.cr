require "db"
require "./lib_sql"

module Libsql
  DATE_FORMAT_SUBSECOND = "%F %H:%M:%S.%L"
  DATE_FORMAT_SECOND    = "%F %H:%M:%S"

  # :nodoc:
  TIME_ZONE = Time::Location::UTC

  def self.check(resource)
    if err = resource.err
      message = String.new(LibSQL.libsql_error_message(err))
      LibSQL.libsql_error_deinit(err)
      raise Exception.new(message)
    else
      resource
    end
  end
end

require "./libsql/*"