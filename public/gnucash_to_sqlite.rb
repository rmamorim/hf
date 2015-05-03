#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'pathname'
require 'active_record'
require 'csv'
require "rexml/document"
require 'sqlite3'
require 'benchmark'



#arq = "/home/ricardo/hansafly/Contabilidade/GnuCash/Hansafly"
#arq = "H:\\Contabilidade\\GnuCash\\Hansafly"
arq = "C:\\Users\\Ricardo\\Dropbox\\Hansa Fly\\Contabilidade\\GnuCash\\Hansafly"


#arq_db = "/home/ricardo/hansafly/Contabilidade/GnuCash/Hansafly.sqlite3"
#arq_db = "/home/ricardo/hf/db/Hansafly.sqlite3"
arq_db = "C:\\Users\\Ricardo\\Dropbox\\hf\\db\\Hansafly.sqlite3"

@db = SQLite3::Database.new(arq_db)



def drop_tabelas
  sql = "DROP TABLE account;"
  @db.execute(sql)

  sql = "DROP TABLE transac;"
  @db.execute(sql)

  sql = "DROP TABLE split;"
  @db.execute(sql)

end


def cria_tabelas
  sql = "CREATE TABLE account (" + \
    "id TEXT," + \
    "name TEXT," + \
    "parent TEXT" + \
    ");"
  @db.execute(sql)

  sql = "CREATE TABLE transac (" + \
    "id TEXT," + \
    "num TEXT," + \
    "date_posted NUMERIC," + \
    "description TEXT" + \
    ");"
  @db.execute(sql)

  sql = "CREATE TABLE split (" + \
    "id TEXT," + \
    "value NUMERIC," + \
    "transac TEXT," + \
    "account TEXT" + \
    ");"
  @db.execute(sql)
  
end


def apaga_registros
  sql = "DELETE FROM account;"
  @db.execute(sql)
  sql = "DELETE FROM transac;"
  @db.execute(sql)
  sql = "DELETE FROM split;"
  @db.execute(sql)

end



Benchmark.bm(20) do |b|

  b.report("drop tabelas") do
    drop_tabelas
  end

  b.report("cria tabelas") do
    cria_tabelas
  end

  b.report("apaga registros") do
    apaga_registros
  end

  b.report("Abrir XML") do
    @xml = REXML::Document.new File.open(arq)
  end

  ##
  ## Account
  ##

  b.report("Gerar array account") do
    @contas = @xml.elements.to_a("//gnc:account")
  end
  b.report("account_a -> sqlite") do
    i = 1
    @contas.each do |e|
      #puts i
      id = e.elements['act:id'].text
      name = e.elements['act:name'].text
      parent = !e.elements['act:parent'].nil? ? e.elements['act:parent'].text : ""
  
      sql = "INSERT INTO account VALUES (" + \
        "'#{id}'," + \
        " '#{name}'," + \
        " '#{parent}'" + \
        ");"
#puts sql
      @db.execute(sql)
  
      i += 1
    end
  end


  ##
  ## Transactions
  ##
  
  b.report("Gerar array transac") do
    @transactions = @xml.elements.to_a("//gnc:transaction")
  end
  b.report("transac_a -> sqlite") do
    i = 1
    @transactions.each do |e|
      id = e.elements['trn:id'].nil? ? "" : e.elements['trn:id'].text
      num = e.elements['trn:num'].nil? ? "" : e.elements['trn:num'].text

      data = e.elements['trn:date-posted'].elements['ts:date'].text
      er = /(....)-(..)-(..)/
      mt = er.match(data)
      #data = mt[0]
      #dt = data.split("-")
      #data = "#{dt[2]}/#{dt[1]}/#{dt[0]}"
      mata = mt

      #date_posted = e.elements['trn:date-posted'].nil? ? "" : e.elements['trn:date-posted'].text
      date_posted = data
      description = e.elements['trn:description'].nil? ? "" : e.elements['trn:description'].text

      sql = "INSERT INTO transac VALUES (" + \
        "'#{id}'," + \
        " '#{num}'," + \
        " '#{date_posted}'," + \
        " '#{description}'" + \
        ");"
      @db.execute(sql)

      transac = id
      splits = e.elements['trn:splits']
      splits.elements.each do |s|        
        #puts "transac = #{transac}"
        id = s.elements['split:id'].nil? ? "" : s.elements['split:id'].text
        value = s.elements['split:value'].nil? ? "" : s.elements['split:value'].text.sub(/\/100/, '').to_f / 100
        account = s.elements['split:account'].nil? ? "" : s.elements['split:account'].text

        sql = "INSERT INTO split VALUES (" + \
          "'#{id}'," + \
          " '#{value}'," + \
          " '#{transac}'," + \
          " '#{account}'" + \
          ");"
        @db.execute(sql)
      end

      i += 1
    end
  end



end
