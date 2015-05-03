# coding: utf-8

class TesteController < ApplicationController

 respond_to :html  

  def index

    @a = []
    @b = []
    @c = []
    @d = []

    path = "c:\/Caixa\/CobCAIXA\/Backup\/"
    #path = "/home/ricardo/hansafly/Caixa/CobCAIXA/Backup/"
    max = nil
    arquivo = ""
    Dir.foreach(path) do |arq|
      #if not [".", ".."].include?(arq) then
      if not File.directory?(path + arq) then

        hora = File.mtime(path + arq)

        if max.nil? then
          max = hora
          arquivo = path + arq
        end

        if hora > max then
          max = hora
          arquivo = path + arq
        end
      end
    end

    #puts "arquivo = #{arquivo}"


    seus_numeros = []
    nossos_numeros = []
    arq = './public/tbTitulos.csv'

    cmd = "rm /home/ricardo/hansafly/BDs/bdcobcaixa.mdb"
    system(cmd)
    cmd = "unzip -u " + arquivo + " -d /home/ricardo/hansafly/BDs/"
    puts cmd
    system(cmd)
    cmd = "mdb-export -D%Y-%m-%d -H -d\\; /home/ricardo/hansafly/BDs/bdcobcaixa.mdb tbTitulos > " + arq
    system(cmd)

    IO.readlines(arq).each do |line|
      t = line.split(';')

      seu_num = t[2].delete("\"").strip
      nosso_numero = t[20].delete("\"").strip

      seus_numeros.push(seu_num)
      nossos_numeros.push(nosso_numero)

    end


    #@boletos = Boleto.find(:all, :order => "boletos.id")
    @boletos = Boleto.find_by_sql("select " +
        " id, seu_numero, nosso_numero, status FROM boletos ORDER BY id desc")

    cont_a = cont_b = 1
    
    for boleto in @boletos do

      ##
      ##  A
      ##

      if boleto.status != 40 then  # 40 = boleto nao impresso
        idx = seus_numeros.index(boleto.seu_numero.strip)
        if idx.nil? then
          a = []
          a.push cont_a
          a.push boleto.id
          a.push boleto.seu_numero.strip.to_s
          a.push "** nao tem **"
          a.push boleto.nosso_numero.strip
          a.push "** nao tem **"
          @a.push a
          cont_a += 1
        else
          if nossos_numeros.fetch(idx) != boleto.nosso_numero then
            a = []
            a.push cont_a
            a.push boleto.id
            a.push boleto.seu_numero.strip.to_s
            a.push seus_numeros.fetch(idx)
            a.push boleto.nosso_numero.strip
            a.push nossos_numeros.fetch(idx)
            @a.push a
            cont_a += 1
          end
        end

        ##
        ##  B
        ##

        idx = nossos_numeros.index(boleto.nosso_numero.strip)
        if idx.nil? then
          a = []
          a.push cont_b
          a.push boleto.id
          a.push boleto.seu_numero.strip.to_s
          a.push "*"
          a.push boleto.nosso_numero.strip
          a.push "** nao tem **"
          @b.push a
          cont_b += 1
        else
          if nossos_numeros.fetch(idx) != boleto.nosso_numero then
            a = []
            a.push cont_b
            a.push boleto.id
            a.push boleto.seu_numero.strip.to_s
            a.push seus_numeros.fetch(idx)
            a.push boleto.nosso_numero.strip
            a.push nossos_numeros.fetch(idx)
            @b.push a
            cont_b += 1
          end
        end
      end
    end


    cont_c = 1
    for sn in seus_numeros do

      ##
      ##  C
      ##

      boleto = Boleto.find(:first, :conditions => 'seu_numero = "' + sn.strip + '"')
      idx = seus_numeros.index(sn)

      if boleto.nil? then
        a = []
        a.push cont_c
        a.push " *** "
        a.push " ** nao tem ** "
        a.push sn
        a.push " *** "
        a.push nossos_numeros[idx]
        @c.push a
        cont_c += 1
      else
        if nossos_numeros[idx] != boleto.nosso_numero then
          a = []
          a.push cont_c
          a.push boleto.id
          a.push boleto.seu_numero.strip.to_s
          a.push seus_numeros[idx]
          a.push boleto.nosso_numero.strip
          a.push nossos_numeros[idx]
          @c.push a
          cont_c += 1                    
        end
      end
    end


    cont_d = 1
    for nn in nossos_numeros do

      ##
      ##  D
      ##

      boleto = Boleto.find(:first, :conditions => 'nosso_numero = "' + nn.strip + '"')
      idx = nossos_numeros.index(nn)

      if boleto.nil? then
        a = []
        a.push cont_d
        a.push " *** "
        a.push " ** "
        a.push seus_numeros[idx]
        a.push " ** nao tem ** "
        a.push nn
        @d.push a
        cont_d += 1
      else
        if seus_numeros[idx] != boleto.seu_numero then
          a = []
          a.push cont_d
          a.push boleto.id
          a.push boleto.seu_numero.strip.to_s
          a.push seus_numeros[idx]
          a.push boleto.nosso_numero.strip
          a.push nossos_numeros[idx]
          @d.push a
          cont_d += 1
        end
      end

    end


    

    #
    #    respond_to do |format|
    #      format.html # index.html.erb
    #      format.xml  { render :xml => @boletos }
    #    end


  end





  def gera_areac
    
    teste = Area.find_by_nome("C")
    exit if !teste.nil? 
    
    c = Area.new()
    c.nome = 'C'
    c.save

    (1..32).each do |i|
      l = c.lotes.new()
      l.numero = i
      l.cod_status_access = 4
      l.superficie = 510
      case (i)
      when 2 then superficie = 504.6
      when 9 then superficie = 612
      when 12 then superficie = 488
      when 16 then superficie = 2193
      when 17 then superficie = 2193
      when 21 then superficie = 488
      when 31 then superficie = 504.6
      else superficie = 510
      end
      l.superficie = superficie
      l.save
    end


  end


end


