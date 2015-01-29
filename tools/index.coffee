# console.log ""

sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("db")

customerSchema = 
  "CREATE TABLE IF NOT EXISTS customers (
    id text,
    title text,
    surname text,
    specialty text,
    addressline1 text,
    addressline2 text,
    addressline3 text,
    addressline4 text,
    suburb text,
    state text,
    postcode text
  )"

db.serialize ->
  data = require "./spec"
  db.run "drop table if exists customers"
  db.run customerSchema
  stmt = db.prepare("INSERT INTO customers (id,title,surname,specialty,addressline1,addressline2,addressline3,addressline4,suburb,state,postcode) VALUES (?,?,?,?,?,?,?,?,?,?,?)")
  for datum in data
    stmt.run datum.ListeeId,datum.PersonTitle,datum.SurName,datum.Specialty,datum.AddressLine1,datum.AddressLine2,datum.AddressLine3,datum.AddressLine4,datum["Dt Locality"],datum["Dt State"],"#{datum["Dt Postcode"]}"
  stmt.finalize()
  # db.each "SELECT * from customers", (err, row) ->
  #   # console.log row.ListeeId + ": " + row.SurName
  #   return

  return

samplesSchema =
  "CREATE TABLE IF NOT EXISTS samples (
    id text,
    category text,
    description text,
    quantities text
  )"

db.serialize ->
  data = require "./samples.json"
  db.run "drop table if exists samples"
  db.run samplesSchema
  stmt = db.prepare("INSERT INTO samples (id,category,description,quantities) VALUES (?,?,?,?)")
  for datum in data
    stmt.run datum
  stmt.finalize()
  # db.each "SELECT * from samples", (err, row) ->
  #   # console.log row.id + ": " + row.description
  #   return

  return

db.close()