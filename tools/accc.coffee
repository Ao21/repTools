csv = require 'csv'
# parse = require('csv-parse');
# transform = require('stream-transform');
fs = require "fs"
Sequence = require('sequence').Sequence
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("accc.db")

schemas =
  mealtypes: 
    "CREATE TABLE IF NOT EXISTS mealtypes (
      mealtype text
    )"
  meetingtypes: 
    "CREATE TABLE IF NOT EXISTS meetingtypes (
      meetingtype text
    )"
  professionalstatuses: 
    "CREATE TABLE IF NOT EXISTS professionalstatuses (
      professionalstatus text
    )"
  venues: 
    "CREATE TABLE IF NOT EXISTS venues (
      name text,
      suburb text,
      state text
    )"
  brandindications:
    "CREATE TABLE IF NOT EXISTS brandindications (
      brandindication text
    )"
  rolemeetinginfo:
    "CREATE TABLE IF NOT EXISTS rolemeetinginfo (
      Role text,
      MeetingType text,
      Proposal text,
      Invitation text,
      Agenda text,
      RSVP text,
      Attendance text,
      EventSummary text,
      Invoice text,
      Speaker text,
      Honorarium text,
      Sponsorship text,
      NP4 text
    )"
  cpdaccreditors:
    "CREATE TABLE IF NOT EXISTS cpdaccreditors (
      cpdaccreditor text
    )"
  cpdcategories:
    "CREATE TABLE IF NOT EXISTS cpdcategories (
      cpdcategory text
    )"

parseCpdAccreditors = (file) ->
  tablename = "cpdaccreditors"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (cpdaccreditor) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseCpdCategorys = (file) ->
  tablename = "cpdcategories"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (cpdcategory) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseMealTypes = (file) ->
  tablename = "mealtypes"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (mealtype) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseMeetingTypes = (file) ->
  tablename = "meetingtypes"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (meetingtype) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseProfessionalStatuses = (file) ->
  tablename = "professionalstatuses"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (professionalstatus) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseVenues = (file) ->
  tablename = "venues"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (name,suburb,state) VALUES (?,?,?)")
      for datum in data
        stmt.run datum[0],datum[1],datum[2]
      stmt.finalize()

parseBrandIndications = (file) ->
  tablename = "brandindications"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (brandindication) VALUES (?)")
      for datum in data
        stmt.run datum[0]
      stmt.finalize()

parseRoleMeetingInfo = (file) ->
  tablename = "rolemeetinginfo"
  csv.parse file, (err, data) ->
    db.serialize ->
      db.run "drop table if exists #{tablename}"
      db.run schemas[tablename]
      stmt = db.prepare("INSERT INTO #{tablename} (Role, MeetingType, Proposal, Invitation, Agenda, RSVP, Attendance, EventSummary, Invoice, Speaker, Honorarium, Sponsorship, NP4) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)")
      for datum,i in data
        continue if i is 0
        datum = datum.map (d) -> d.replace /\|/, "\n"
        stmt.run datum[0],datum[1],datum[2],datum[3],datum[4],datum[5],datum[6],datum[7],datum[8],datum[9],datum[10],datum[11],datum[12],datum[13]
      stmt.finalize()

sequence = Sequence.create()
sequence.then (next) ->
  file = fs.readFileSync "data/cpd-accreditor.csv", {encoding:"utf8"}
  parseCpdAccreditors file
  next()
sequence.then (next) ->
  file = fs.readFileSync "data/cpd-category.csv", {encoding:"utf8"}
  parseCpdCategorys file
  next()
sequence.then (next) ->
  file = fs.readFileSync "data/mealType.csv", {encoding:"utf8"}
  parseMealTypes file
  next()

sequence.then (next) ->
  file = fs.readFileSync "data/meetingTypes.csv", {encoding:"utf8"}
  parseMeetingTypes file
  next()

sequence.then (next) ->
  file = fs.readFileSync "data/profstatus.csv", {encoding:"utf8"}
  parseProfessionalStatuses file
  next()

sequence.then (next) ->
  file = fs.readFileSync "data/venues.csv", {encoding:"utf8"}
  parseVenues file
  next()

sequence.then (next) ->
  file = fs.readFileSync "data/brandIndication.csv", {encoding:"utf8"}
  parseBrandIndications file
  next()

sequence.then (next) ->
  file = fs.readFileSync "data/meetingInfo.csv", {encoding:"utf8"}
  parseRoleMeetingInfo file
  next()
  