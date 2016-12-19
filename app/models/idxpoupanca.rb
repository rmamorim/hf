# coding: utf-8


class Idxpoupanca < ActiveRecord::Base

  @cache_idx = {}

  def Idxpoupanca.get_idx_poupanca_mes dt, tipo
    ##
    ## Tratar o caso de o índice ainda não estar definido
    ##

    ## Caso de sem correção
    if tipo == 43 then
      return 1
    end

    key = dt.beginning_of_month.to_s + "-" + tipo.to_s
    if !@cache_idx.has_key?(key)
      idx = Idxpoupanca.first(:conditions => ["mes = ? AND tipo = ?", dt.beginning_of_month.to_date, tipo])
      @cache_idx[key] = idx
    else
      idx = @cache_idx[key]
    end

    #puts "#######################"
    #puts "#######################"
    #puts "#######################"
    #puts "#######################"
    #puts dt.beginning_of_month.to_date
    #puts idx.indice
    #puts "***********************"
    #puts "***********************"
    #puts "***********************"
    #puts "***********************"

    return !idx.nil? ? idx.indice : 1
  end


  def Idxpoupanca.get_idx_poupanca_dias dtFinal, dias, tipo

    ## Caso de sem correção
    if (tipo.nil?) or (tipo == 43) then
      return 1
    end

    ## Caso IGPM  - substitue por poupanca, ja que nao implementa calculo
    tipo = (tipo == 44) ? 45 : tipo

    dt_sql = format('%s-%s-%s', dtFinal.year, dtFinal.month, dtFinal.day)
    sql = format('select *' \
        + ' from idxpoupancas' \
        + ' where mes <= "%s" AND tipo = "%i"' \
        + ' order by mes desc' \
        + ' limit 3' \
        , dt_sql, tipo)

    idxs = Idxpoupanca.find_by_sql(sql)
    soma = 0
    idxs.each do |i|
      soma += i.indice
    end
    idx_m = soma / idxs.size
    idx_dias = (1.0 + (idx_m / 100.0)) ** (dias/30.0)

    return idx_dias
  end





  def Idxpoupanca.mesmo_mes? d1, d2
    if (d1.year == d2.year) and (d1.month == d2.month) then
      return true
    else
      return false
    end
  end




  def Idxpoupanca.calcula_indice_entre_dates dtInicial, dtFinal, tipo

    return 1 if dtInicial > dtFinal
    dt = dtInicial
    if !mesmo_mes?(dtInicial, dtFinal) then
      idx = 1
      dt = dtInicial + 1.month
      while !mesmo_mes?(dt, dtFinal) do
        idx_mes = self.get_idx_poupanca_mes(dt, tipo)
        idx = idx * (1 + (idx_mes / 100))
        dt = dt + 1.month
      end
      idx_mes = self.get_idx_poupanca_mes(dt, tipo)
      idx = idx * (1 + (idx_mes / 100))
      dias = (dtFinal - dt).to_i
    else
      idx = 1
      dias = (dtFinal - dtInicial).to_i
    end
    idx_dias = get_idx_poupanca_dias(dtFinal, dias.abs, tipo)
    if dias > 0 then
      return idx * idx_dias
    else
      return idx / idx_dias
    end

  end





  def Idxpoupanca.calcula_indice_entre_datas dtInicial, dtFinal, tipo
#    puts "----------------"
#    puts dtInicial
#    puts dtFinal
#    puts "----------------"

    dt = dtInicial
    if not mesmo_mes?(dtInicial, dtFinal) then
#puts 'nao mesmo mes'
      idx = 1
      dt = dtInicial.advance(:months => 1)
      while not mesmo_mes?(dt, dtFinal) do

        idx_mes = self.get_idx_poupanca_mes(dt, tipo)
        idx = idx * (1 + (idx_mes / 100))
        puts "# #{idx_mes} ---- #{dt} #"
        dt = dt.advance(:months => 1)

#puts "dt = #{dt}"
#puts "idx_mes = #{idx_mes}"
#puts "idx = #{idx}"
      end
      idx_mes = self.get_idx_poupanca_mes(dt, tipo)
      puts "## #{idx_mes} ---- #{dt} ##"
      idx = idx * (1 + (idx_mes / 100))
      dias = (dtFinal - dt) / 86400
    else
#puts 'mesmo mes'
      idx = 1
      dias = (dtFinal - dtInicial) / 86400
    end

#puts ">>>>>>>>> dias = #{dias}"

    idx_dias = get_idx_poupanca_dias(dtFinal, dias.abs, tipo)
    if dias > 0 then
      r = idx * idx_dias
    else
      r = idx / idx_dias
    end
    puts "### #{(idx_dias-1)*100} ---- ###"
    return r
  end


  
  def Idxpoupanca.teste
    puts self.calcula_indice_entre_datas '8/8/2008', '19/11/2009'
    puts self.calcula_indice_entre_datas '8/8/2008', '03/12/2009'
    puts self.calcula_indice_entre_datas '8/11/2009', '03/12/2009'
    puts self.calcula_indice_entre_datas '8/11/2009', '13/12/2009'
    puts self.calcula_indice_entre_datas '8/11/2009', '13/11/2009'
    puts self.calcula_indice_entre_datas '8/12/2009', '13/12/2009'


    puts '---'
    puts self.calcula_indice_entre_datas '15/02/2006', '20/01/2010'
    puts self.calcula_indice_entre_datas '15/02/2006', '23/03/2010'
    puts '---'
    


  end


  
end
