# coding: utf-8

require 'win32ole'
require 'fileutils'
 


#strftime
#========
#
# %a	The abbreviated weekday name (``Sun'')
# %A	The full weekday name (``Sunday'')
# %b	The abbreviated month name (``Jan'')
# %B	The full month name (``January'')
# %c	The preferred local date and time representation
# %d	Day of the month (01..31)
# %H	Hour of the day, 24-hour clock (00..23)
# %I	Hour of the day, 12-hour clock (01..12)
# %j	Day of the year (001..366)
# %m	Month of the year (01..12)
# %M	Minute of the hour (00..59)
# %p	Meridian indicator (``AM'' or ``PM'')
# %S	Second of the minute (00..60)
# %U	Week number of the current year, starting with the first Sunday as the first day of the first week (00..53)
# %W	Week number of the current year, starting with the first Monday as the first day of the first week (00..53)
# %w	Day of the week (Sunday is 0, 0..6)
# %x	Preferred representation for the date alone, no time
# %X	Preferred representation for the time alone, no date
# %y	Year without a century (00..99)
# %Y	Year with century
# %Z	Time zone name
# %%	Literal ``%'' character





class Biblioteca

  def initialize
  end



  def Biblioteca.backup_mysql
    path = "/home/ricardo/hansafly/backup/"
    data = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
    arq = "dump_hansafly_#{data}.sql"

    cmd = "mysqldump -u root -pcarrera hansafly > #{path}#{arq}"
    system(cmd)
    return arq
  end



  def Biblioteca.restore_mysql arq
    path = "/home/ricardo/hansafly/backup/"
    cmd = "mysql hansafly -u root -pcarrera < #{path}#{arq}"
    system(cmd)
  end




  def Biblioteca.soma_mesdt s

    dt = s.split("/")
    y = dt[2].to_i
    m = dt[1].to_i
    d = dt[0].to_i

    if m < 12 then
      m = m + 1
    else
      m = 1
      y = y + 1
    end

    if d == 31
      if (m == 4) or (m == 6) or (m == 9) or (m == 11) then
        d = 30
      end
      if (m == 2) then
        d = 28
      end
    end

    if ((d == 30) or (d == 29)) and (m == 2)
      d = 28
    end
  
    return d.to_s + "/" + m.to_s + "/" + y.to_s

  end


  def Biblioteca.soma_meses_dt s, m
    r = s
    for i in 1..m
      r = self.soma_mesdt(r)
    end
    return r
  end


  def Biblioteca.to_my_moeda s
    a = Biblioteca.arredonda_float(s,2).to_s
    r = a.to_s.sub(/[.]/,",")
    #r = "R$ " + r[0..-3]  Nao me lembro a razao

    casas_faltantes = 3 - (r.size - r.index(","))
    complemento = "0" * casas_faltantes
    r = "R$ " + r + complemento

    return r
  end



  def Biblioteca.date2time d
    year = d.year
    month = d.month
    day = d.day
    return Time::local(year,month,day)
  end


  def Biblioteca.time2date t
    year = t.year
    month = t.month
    day = t.day
    return Date.new(y = year.to_i, m = month.to_i, d = day.to_i)
  end




  def Biblioteca.time2sicob d
    return d.strftime("#%m/%d/%Y#")
  end


  def Biblioteca.date2sicob d
    return Biblioteca.time2sicob(Biblioteca.date2time(d))
  end



  def Biblioteca.dt_mysql_to_data dt
    dt = dt.to_s
    ano = dt[0,4]
    mes = dt[5,2]
    dia = dt[8,2]
    r = dia + "/" + mes + "/" + ano
    r = r.to_s
    return r
  end


  

  def Biblioteca.dt_mysql_to_s dt
    ano = dt[0,4]
    mes = dt[5,2]
    dia = dt[8,2]
    return dia + "/" + mes + "/" + ano
  end

  def Biblioteca.dt_mysql_to_time dt
    ano = dt[0,4]
    mes = dt[5,2]
    dia = dt[8,2]
    Time.local(ano,mes,dia)
  end


  def Biblioteca.dt_access_to_dt_mysql dt
    if dt == ""  then return "" end
    ano = dt[0,4]
    mes = dt[5,2]
    dia = dt[8,2]
    return "#" + mes + "/" + dia + "/" + ano + "#"
  end

  def Biblioteca.dt_mysql_to_dt_access dt
    if dt == "" then return "" end
    ano = dt[0,4]
    mes = dt[5,2]
    dia = dt[8,2]
    return "#" + mes + "/" + dia + "/" + ano + "#"
  end


  def Biblioteca.corrige_piso_dia d, piso
    #    dt = s.to_s.split("-")
    #    ano = dt[0]
    #    mes = dt[1]
    #    dia = dt[2]
    #    if dia.to_i < piso.to_i
    #      dia = piso.to_s
    #    end
    #    return ano + "-" + mes + "-" + dia
    
    dias = piso.to_i - d.day
    return (dias > 0) ? d.advance(:days => dias) : d
  end


  def Biblioteca.date2data d
    s = d.day.to_s + '/' + d.month.to_s + '/' + d.year.to_s
    return s
  end



  def Biblioteca.data2date s
    if s.strip == ""
      return nil
    end
    dt = s.split("/")
    return Date.new(y=dt[2].to_i, m=dt[1].to_i, d=dt[0].to_i)
  end


  def Biblioteca.datacsv_to_datasql s
    #printf "[1] -> %s\n", s
    if s == "" then return "" end
    dt = s.split("/")
    ano = dt[2].to_i
    ano = ano < 100 ? ano + 2000 : ano
    mes = dt[1].to_s.size == 1 ? "0" + dt[1].to_s : dt[1].to_s
    dia = dt[0].to_s.size == 1 ? "0" + dt[0].to_s : dt[0].to_s
    r = format("%s-%s-%s", ano, mes, dia)
    #printf "[2] -> %s\n", r
    return r
  end


  def Biblioteca.data_cef_to_sql s
    if s == "" then return "" end
    ano = s[4,4]
    mes = s[2,2]
    dia = s[0,2]
    r = format("%s-%s-%s", ano, mes, dia)
    return r
  end



  def Biblioteca.moeda_cef_to_sql s
    while s[0,1] == 0 do
      s = s[1,s.size-1]
    end
    r = s.to_f / 100
    return r.to_s
  end


  
  def Biblioteca.trata_string_nil s
    return s.nil? ? "" : s
  end
  
  
  def Biblioteca.mes_atual
    mes = DateTime.now.strftime("%m").to_i
    mes = mes - 1
    ano = DateTime.now.strftime("%Y").to_i
    
    
    if mes == 1 then
      mes = 12
      ano = ano - 1      
    end
    
    final = format("%s-%s-31", ano, mes)
    r = format("between '1900-01-01' and '%s'", final)
    
    return r
  end
  
  
  
  def Biblioteca.format_area_lote area, lote
    return area.to_s + "-" + lote.to_s
  end
  
  
  def Biblioteca.format_entrada qtd, valor
    if qtd == 0 then 
      return ""      
    end   
    if qtd == 1 then 
      return valor.to_f.to_currency(Currency::BRL)
    end    
    return qtd.to_s + " x " + valor.to_f.to_currency(Currency::BRL)    
  end


  def Biblioteca.format_parcelas qtd1, valor1, qtd2, valor2
    if qtd1.nil? or qtd1 == 0 then 
      return ""      
    end   
    
    if qtd1 == 1 then 
      p1 = valor1.to_f.to_currency(Currency::BRL)
    else
      p1 = qtd1.to_s + " x " + valor1.to_f.to_currency(Currency::BRL)      
    end    
    
    if qtd2.nil? or qtd2 == 0 then 
      return p1
    end     

    if qtd2 == 1 then 
      return p1 + " + " + valor1.to_f.to_currency(Currency::BRL)
    else
      return p1 + " + " + qtd2.to_s + " x " + valor2.to_f.to_currency(Currency::BRL)      
    end    

    
  end

  
  def Biblioteca.format_data d
    data = d.nil? ? "" : d.strftime("%d/%m/%Y")             
    return data
  end
  

  def Biblioteca.status_lote cod    
    case (cod)
    when 1 then status = "Em pagamento"
    when 2 then status = "Quitado"
    when 3 then status = "Escriturado"
    when 4 then status = "Para venda"
    when 5 then status = "Reservado"
    when 6 then status = "Pendente"
    when 7 then status = "Uso interno"  
    else status = ""
    end       
    return status
  end

  
  def Biblioteca.status_parcela cod
    case (cod)
    when 1 then status = "Em aberto"
    when 2 then status = "Título CEF"
    when 3 then status = "Recibo do corretor sem validação"
    when 4 then status = "Recibo do corretor com validação"
    when 5 then status = "Pagos em mãos"
    when 6 then status = "Contador informa pagamento"
    when 7 then status = "Contador não informa pagamento"  
    when 8 then status = "Fraude do corretor - contratos diferentes"
    when 9 then status = "Depositado na conta do corretor"
    when 10 then status = "Desviado pelo corretor"
    when 11 then status = "Cheque pré-datado"  
    when 12 then status = "Crédito por permuta"  
    when 13 then status = "Título emitido e não pago"
    when 14 then status = "Depositado na conta da Hansa Fly"
    when 15 then status = "Apresentou comprovante pg parcela"  
    else status = ""
    end
    return status
  end
  
   


  def Biblioteca.format_currency c
    return c.nil? ? "" : c.to_f.to_currency(Currency::BRL)
  end


  def Biblioteca.get_dia_databd s
    if s.strip == "" then
      return nil
    end
    dt = s.split("-")
    return dt[2].to_i
  end


  def Biblioteca.get_mes_databd s
    if s.strip == "" then
      return nil
    end
    dt = s.split("-")
    return dt[1].to_i
  end


  def Biblioteca.get_ano_databd s
    if s.strip == "" then
      return nil
    end
    dt = s.split("-")
    return dt[0].to_i
  end


  def Biblioteca.arredonda_float f, c
    casas = (10.0**c.to_f).to_f
    r = (f * casas).round / casas
    return r
  end



  def Biblioteca.converte_texto s
    return s
  end



  def Biblioteca.get_extrato_gnucash
    #arq_db = "/home/ricardo/hansafly/Contabilidade/GnuCash/Hansafly.sqlite3"
    arq_db = "/home/ricardo/hf/db/Hansafly.sqlite3"
    arq_db = "C:\\Users\\Ricardo\\Dropbox\\hf\\db\\Hansafly.sqlite3"

    @db = SQLite3::Database.new(arq_db)

    sql = "SELECT id FROM account WHERE name = 'Ricardo'"
    r = @db.execute(sql)

    id = r[0]
    sql = "SELECT" + \
      " p.name," + \
      " a.name," + \
      " t.description," + \
      " t.date_posted," + \
      " s.value" + \
      " FROM transac t" + \
      " JOIN split s" + \
      " ON s.transac = t.id" + \
      " JOIN account a" + \
      " ON a.id = s.account" + \
      " JOIN account p" + \
      " ON a.parent = p.id" + \
      " WHERE t.id IN (SELECT transac FROM split WHERE account = '#{id}')" + \
      " AND s.account <> '#{id}'" + \
      " order by t.date_posted;"
    r = @db.execute(sql)

    resposta = []

    i = 0
    saldo = 0.0
    r.each do |e|
      parent = e[0].strip
      conta = e[1].strip
      descricao = e[2].strip
      data = e[3][0,10]
      credito = -(e[4].to_f)
      saldo = saldo + credito

      a = []
      a.push(dt_mysql_to_data(data))
      a.push(parent)
      a.push(conta)
      a.push(descricao)
      
      credito > 0 ? a.push(format_currency(credito)) : a.push('')
      credito > 0 ? a.push('') : a.push(format_currency(-credito))
      a.push(format_currency(saldo))

      resposta.push(a)
    end

    return resposta
  end



end


######################################################



class Minha

  def initialize
    @codsacs = {}
    @cpfs = {}
    @inserts = []
  end


  def get_tb_sacado
    #cmd = "mdb-export -D%Y-%m-%d -H -d\\; /home/ricardo/hansafly/BDs/bdcobcaixa.mdb tbSacado > tbSacado.csv"
    cmd = "mdb-export -D%Y-%m-%d -H -d\\; /home/ricardo/hansafly/Caixa/CobCAIXA/bdcobcaixa.mdb tbSacado > tbSacado.csv"
    #cmd = "mdb-export -D%Y-%m-%d -H -d\\; C:\\Caixa\\CobCAIXA\\bdcobcaixa.mdb tbSacado > tbSacado.csv"
    system(cmd)

    arq = File.dirname(__FILE__) + '/../tbSacado.csv'
    IO.readlines(arq).each do |line|
      tokens = line.split(';')
      cod_sacado = (tokens[1].delete'"').strip
      cpf = tokens[6].delete'"'
      @cpfs[cod_sacado] = cpf
      #printf("cod_sac = %s   -->  cpf = %s\n", cod_sacado, cpf)
    end
  end


  def get_tb_sacado_windows
    cnn = WIN32OLE.new('ADODB.Connection')
    cnn.Open('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\\Caixa\\acesso_cef.mdb')

    sql = "SELECT * FROM tbSacado"
    rs = WIN32OLE.new('ADODB.Recordset')
    rs.Open(sql, cnn)
    data = rs.GetRows.transpose
    data.each do |d|
      cod_sacado = d[1]
      cpf = d[6]
      @cpfs[cod_sacado] = cpf
    end

    rs.close
    cnn.close
  end



  def cpf_to_codsac cpf
    if @cpfs.size == 0 then get_tb_sacado_windows end
    codsac = (i = (@cpfs.values).index(cpf.to_s)).nil? ? nil : @cpfs.keys[i]
    #puts "codsac = #{codsac}"
    return codsac
  end



  def codsac_to_cpf cod_sac
    if @cpfs.size == 0 then get_tb_sacado end
    cpf = @cpfs[cod_sac]
    return cpf
  end



end

