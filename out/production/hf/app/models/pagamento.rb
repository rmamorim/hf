# coding: utf-8


class Pagamento < ActiveRecord::Base
  belongs_to :boleto
  #has_one :retorno


  def efetua_pagamento boleto,\
          status_boleto, \
          status_pagamento, \
          valor_multa, \
          valor_juros, \
          valor_desconto, \
          valor_tarif_banco, \
          valor_pago, \
          data_pagamento, \
          comentarios

    self.boleto_id = boleto.id
    self.status = status_pagamento
    self.valor_titulo = boleto.valor_titulo
    self.valor_multa = valor_multa
    self.valor_juros = valor_juros
    self.valor_desconto = valor_desconto
    self.valor_tarif_banco = valor_tarif_banco
    self.valor_pago = valor_pago
    self.data_pagamento = data_pagamento.to_s.strip
    self.data_processamento = DateTime.now.strftime("%Y-%m-%d").to_s.strip
    self.comentarios = comentarios
    self.save
  end



  def Pagamento.proc_csv_pagamento_boletos arq
    CSV::Reader.parse(File.open("dados_csv/"+ arq, 'rb')) do |row|
      #break if !row[0].is_null && row[0].data == 'stop'
      if row[0] != "seu_numero" then
        p row
        b = Boleto::get_boleto(row[0])
        if ! b.promissoria.pago? then
          b.efetua_pagamento row[1], row[2], row[3], row[4], row[5], row[6], row[7], datacsv_to_datasql(row[8].to_s), row[9]
        else
          puts "   >>> Promissoria jah paga!"
        end
      end
    end
  end


  def Pagamento.canal_pgto_to_cod_status_pagamento cod
    case (cod)
    when "02" then s = 36
    when "03" then s = 37
    when "04" then s = 35
    when "05" then s = 35
    when "06" then s = 35
    when "07" then s = 35
    when "08" then s = 35
    else s = 0
    end
    return s
  end


def Pagamento.canal_pgto_to_s cod
  case (cod)
  when "02" then s = "Casa Loterica"
  when "03" then s = "Agencia da CEF"
  when "04" then s = "Compensacao Eletronica"
  when "05" then s = "Compensacao Convencional"
  when "06" then s = "Outros Canais"
  when "07" then s = "Correspondente Bancario"
  when "08" then s = "Cartorio"
  else s = ""
  end
  return s
end


def Pagamento.forma_pgto_to_s cod
  case (cod)
  when "01" then s = "Dinheiro"
  when "02" then s = "Cheque"
  else s = ""
  end
  return s
end



  def Pagamento.boleto_pago boleto, retorno

    e = []
    #case boleto.status
    #when 38 then
      pagamento = Pagamento.new
      pagamento.boleto_id = boleto.id

      canal_pagamento = retorno.dados_pagamento[0,2]
      forma_pagamento = retorno.dados_pagamento[2,2]
      pagamento.status = Pagamento::canal_pgto_to_cod_status_pagamento(canal_pagamento)
      pagamento.valor_titulo = boleto.valor_titulo
      pagamento.valor_juros = retorno.encargos
      pagamento.valor_multa = 0
      pagamento.valor_desconto = retorno.descontos + retorno.abatimento
      pagamento.valor_tarif_banco = retorno.tarifa
      pagamento.valor_pago = retorno.credito
      pagamento.data_pagamento = retorno.data_pagamento
      pagamento.data_processamento = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
      pagamento.comentarios = format("Processado automaticamente em %s. Pagos %s no dia %s, em %s em %s. No dia %s foram depositados %s na conta corrente CEF. Foi descontada tarifa bancaria de %s.",
        Biblioteca::format_data(pagamento.data_processamento),
        Biblioteca::to_my_moeda(pagamento.valor_pago),
        Biblioteca::format_data(pagamento.data_pagamento),
        Pagamento::forma_pgto_to_s(forma_pagamento),
        Pagamento::canal_pgto_to_s(canal_pagamento),
        Biblioteca::format_data(retorno.data_credito),
        Biblioteca::to_my_moeda(retorno.credito),
        Biblioteca::to_my_moeda(retorno.tarifa)
      )
      pagamento.save

      boleto.status = 39  # Titulo pago
      boleto.promissoria.cod_status = pagamento.status
      boleto.promissoria.save
      boleto.save

      e.push pagamento.comentarios

    #end

    return e

  end


end
