# coding: utf-8

class PromissoriasController < ApplicationController


  def show
    @promissoria = Promissoria.find(params[:id])
  end

  
  def pagamento
    @promissoria = Promissoria.find(params[:id])
  end


  def pagar_promissoria

    ##
    ## Atencao!
    ## VERIFICAR se exste algum efeito colateral de se registrar um pagamento sem criar um boleto associado!
    ## Ou seja, com o objeto Boleto com a maioria dos atrubutos sendo nil
    ##


    @promissoria = Promissoria.find(params[:id])
    dados = params[:promissoriab]
    @dados = dados

    status_boleto = 40      # 40 - Sem boleto
    status_pagamento = dados["status_pagamento"]
    valor_multa = dados["valor_multa"]
    valor_juros = dados["valor_juros"]
    valor_desconto = dados["valor_desconto"]
    valor_tarif_banco = 0
    valor_pago = dados["valor_pago"]
    dia = dados["data_pagamento(3i)"]
    mes = dados["data_pagamento(2i)"]
    ano = dados["data_pagamento(1i)"]
    data_pagamento = Time.local(ano.to_i, mes.to_i, dia.to_i)
    comentarios = dados["comentarios"]

    @promissoria.cod_status = status_pagamento
    @promissoria.save

    boleto = Boleto.new
    boleto.status = 40 # Sem Boleto
    boleto.valor_original = valor_pago
    boleto.valor_titulo = valor_pago
    boleto.promissoria_id = @promissoria.id
    boleto.save

    pagamento = Pagamento.new
    pagamento.boleto = boleto
    pagamento.status = status_pagamento

    pagamento.valor_titulo = @promissoria.valor_original
    pagamento.valor_multa = valor_multa
    pagamento.valor_juros = valor_juros
    pagamento.valor_desconto = valor_desconto
    pagamento.valor_tarif_banco = valor_tarif_banco
    pagamento.valor_pago = valor_pago
    pagamento.data_pagamento = data_pagamento.to_s.strip
    pagamento.data_processamento = DateTime.now.strftime("%Y-%m-%d").to_s.strip
    pagamento.comentarios = comentarios
    pagamento.save

    @lote = @promissoria.venda.lote
  end




end
