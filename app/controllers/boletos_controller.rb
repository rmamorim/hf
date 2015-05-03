# coding: utf-8

class BoletosController < ApplicationController


  def new
    @boleto = Boleto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @boleto }
    end
  end



  def pagamento
    @boleto = Boleto.find(params[:id])
  end

  


  def pagar_boleto
    @boleto = Boleto.find(params[:id])
    dados = params[:boletob]
    @dados = dados

    status_boleto = dados["status_pagamento"]
    status_pagamento = dados["status_pagamento"]
    valor_multa = dados["valor_multa"]
    valor_juros = dados["valor_juros"]
    valor_desconto = dados["valor_desconto"]
    valor_tarif_banco = dados["valor_tarifa"]
    valor_pago = dados["valor_pago"]
    dia = dados["data_pagamento(3i)"]
    mes = dados["data_pagamento(2i)"]
    ano = dados["data_pagamento(1i)"]
    data_pagamento = Time.local(ano.to_i, mes.to_i, dia.to_i)
    comentarios = dados["comentarios"]

    @boleto.efetua_pagamento \
      status_boleto, \
      status_pagamento, \
      valor_multa, \
      valor_juros, \
      valor_desconto, \
      valor_tarif_banco, \
      valor_pago, \
      data_pagamento, \
      comentarios
    
    redirect_to(:controller => 'promissorias', :action => 'show', :id => @boleto.promissoria.id)
  end




  def processa_gera_avulsos
    dados = params[:boleto]
    @busca = dados["valor"]

    where = "id IN (17077,17078,17079,17080,17081,17082,17083)"
    promissorias = Promissoria.where(where)

    boletos = []
    promissorias.each do |p|
      boletos << p.gera_boleto_automatico
    end

    @promissorias = promissorias
    @boletos = boletos
  end



  def gera_avulsos

  end


  def gera_mes
    @year = params[:year]
    @month = params[:month]

    ##
    ## Antigo
#    @dados = Promissoria.new.gera_boletos_mesb @year, @month

    ##
    ## Novo
    @dados = Promissoria.new.gera_boletos_mes_new @year, @month


    dt = Time::local(@year, @month, 1).next_month.to_s(:db)
    sql = <<SQL_TYPE
SELECT p.* from promissorias p
LEFT JOIN boletos b ON b.promissoria_id = p.id
JOIN vendas v ON p.venda_id = v.id
JOIN lotes l ON v.lote_id = l.id
JOIN areas a ON l.area_id = a.id
WHERE p.data_vencimento < '#{Time.now.to_s(:db)}'
AND b.id ISNULL
AND p.cod_status not in (17,20,42)    -- (Desviado pelo corretor, contador nao informa pg, dispensado pela HF)
AND a.id not in (4, 9) 									-- Casas, Sítio cotia
SQL_TYPE

    @promissorias = Promissoria.find_by_sql(sql)

  end


  def choice_novo
    @lote = Lote.find(params[:lote])
    @venda = @lote.get_venda
    @promissoria = Promissoria.find(params[:promissoria])
  end


  def choice
    @lote = Lote.find(params[:lote])
    @venda = @lote.get_venda
    @promissoria = Promissoria.find(params[:promissoria])
  end

  ## 46 - Normal sem juros
  ## 47 - Atrasado - boleto especial
  ## 48 - Normal com juros
  ## 49 - Antigo


  def gera_boleto_manual_vincendo
    promissoria = Promissoria.find(params[:id])
    dados = params[:boleto]

    dia = dados["data_vencimento(3i)"]
    mes = dados["data_vencimento(2i)"]
    ano = dados["data_vencimento(1i)"]
    data_vencimento = Date.new(ano.to_i, mes.to_i, dia.to_i)

    options = {}
    options[:dias_permitido_receber] = dados["dias_permitido_receber"]
    #dias_para_pagar_apos_emissao
    options[:valor] = dados["valor"]
    options[:data_vencimento] = data_vencimento
    promissoria.gera_boleto_vincendo2 options
    @boletos = Boleto.all(:conditions => "data_emissao = '#{Time.now.to_s(:db)[0,10]}'" )
  end


  def gera_boleto_manual_vencido
    promissoria = Promissoria.find(params[:id])
    dados = params[:boleto]

    dia = dados["data_vencimento(3i)"]
    mes = dados["data_vencimento(2i)"]
    ano = dados["data_vencimento(1i)"]
    data_vencimento = Date.new(ano.to_i, mes.to_i, dia.to_i)

    options = {}
    options[:desconto] = dados["desconto"]
    options[:data_vencimento] = data_vencimento

    promissoria.gera_boleto_vencido options
    @boletos = Boleto.all(:conditions => "data_emissao = '#{Time.now.to_s(:db)[0,10]}'" )
  end





  def new_sem_juros
    promissoria = Promissoria.find(params[:id])
    dados = params[:boleto]

    dia = dados["data_vencimento(3i)"]
    mes = dados["data_vencimento(2i)"]
    ano = dados["data_vencimento(1i)"]
    data_vencimento = Time.local(ano.to_i, mes.to_i, dia.to_i)
    dia = dados["data_base(3i)"]
    mes = dados["data_base(2i)"]
    ano = dados["data_base(1i)"]
    data_base = Time.local(ano.to_i, mes.to_i, dia.to_i)

    #flag_especial = dados["especial"]
    #tipo_boleto = flag_especial.to_i == 1 ? 47 : 48
    tipo_boleto = 46 # Normal
    @s = promissoria.gera_boletob(tipo_boleto, data_vencimento, data_base)
  end



  def new_com_juros
    promissoria = Promissoria.find(params[:id])
    dados = params[:boleto]

    dia = dados["data_vencimento(3i)"]
    mes = dados["data_vencimento(2i)"]
    ano = dados["data_vencimento(1i)"]
    data_vencimento = Time.local(ano.to_i, mes.to_i, dia.to_i)
    dia = dados["data_base(3i)"]
    mes = dados["data_base(2i)"]
    ano = dados["data_base(1i)"]
    data_base = Time.local(ano.to_i, mes.to_i, dia.to_i)

    flag_especial = dados["especial"]

    tipo_boleto = flag_especial.to_i == 1 ? 47 : 48
    @s = promissoria.gera_boletob(tipo_boleto, data_vencimento, data_base)
  end


end
