require 'sqlite3'

  arq_db = "development.sqlite3"
  db = SQLite3::Database.new(arq_db)

  #sql = "SELECT * FROM lotes"
  #rows = db.execute(sql)

  1.upto(81) do |i|
    sql = "INSERT INTO lotes (numero, area_id, cod_status_access, cod_vendedor_access) VALUES (#{i}, 31, 4, 1)"
    puts sql
    db.execute(sql)
  end