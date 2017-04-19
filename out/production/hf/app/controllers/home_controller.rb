# coding: utf-8

class HomeController < ApplicationController


  def backup
    data = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")

    db_file = "development.sqlite3"
    #db_path =  "/home/ricardo/hf/db/"
    #db_path =  "C:\\users\\Ricardo\\dropbox\\hf\\db\\"
    db_path =  "C:\\hf\\db\\"

    #backup_path = "/home/ricardo/hansafly/backup/"
    #backup_path = "H:\\backup\\"
    backup_path = "C:\\Caixa\\backup\\"

    #backup_file = "sqlite_hansafly_#{data}.tar.gz"
    backup_file = "sqlite_hansafly_#{data}.rar"

    system("copy #{db_path}#{db_file} #{backup_path}")
    system("rar a #{backup_path}#{backup_file} #{backup_path}#{db_file}")

    @arq = "#{backup_path}#{backup_file}"
  end


  def backup_mysql
    @arq = Biblioteca::backup_mysql
  end


  def restore
    if !params[:arq_nome].nil? then
      arq = params[:arq_nome]
      Biblioteca::restore_mysql arq
      @msg = "Backup #{arq} recuperado com êxito!"
    else
      @msg = ""
    end

    path = "/home/ricardo/hansafly/backup/"
    Dir.chdir(path)
    cont = 0
    data_ant = ""
    @arqs = []

    #for arq in Dir.glob('*.sql').sort do
    Dir.glob('*.sql').sort{|a,b| File.stat(b).mtime <=> File.stat(a).mtime}.each do |arq|
      if not [".", ".."].include?(arq) then
        dia =  File.stat(arq).mtime.day
        mes =  File.stat(arq).mtime.month
        data = "#{dia}-#{mes}"
        if data != data_ant then
          cont = cont + 1
        end
        data_ant = data
        if cont <= 2 then
          @arqs.push arq
        end
      end
    end
  end





end
