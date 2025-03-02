require "./spec_helper"

describe Libsql do
  it "creates a new table" do
    DB.open("libsql://0.0.0.0:8080?auth_token=fake") do |connection|
      connection.exec("DROP TABLE contacts;")
      connection.exec("CREATE TABLE contacts ( name text );")
    end
  end
end
