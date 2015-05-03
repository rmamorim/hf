# coding: utf-8

class RecebidosCefMesController < ApplicationController

  def index
    
  end


  def show

  end



  def myshow
    @year = params[:year]
    @month = params[:month]


    sql = <<SQL_TYPE
select * from retornos
 where (strftime('%Y-%m',data_credito) = '#{Time::local(@year,@month,1).to_s(:db)[0,7]}')
 order by data_credito, ltrim(dados_pagamento,4);
SQL_TYPE


    @total = 0
    @lista = []
    lista = Retorno.find_by_sql(sql)

    lista.each do |r|

      data_credito = r.data_credito
      dados_pagamento = r.dados_pagamento
      forma_pagamento = Pagamento::canal_pgto_to_s(dados_pagamento[0,2]) \
        + ' - ' + Pagamento::forma_pgto_to_s(dados_pagamento[2,2])


      valor_pago = r.credito + r.tarifa
      puts ">>>>> retorno.id = #{r.id}"
      puts ">>>>> retorno.nosso_numero = #{r.nosso_numero}"
      boleto = Boleto.find_by_nosso_numero(r.nosso_numero.strip)
      puts ">>>>> boleto.id = #{boleto.id}"
      puts "---------------------------------"

#      b2 = Boleto.find


      seu_numero = boleto.seu_numero

      a = []
      a.push(data_credito)
      a.push(forma_pagamento)
      a.push(valor_pago)
      a.push(seu_numero)
      @lista.push(a)
      @total = @total + valor_pago

    end

  end

end
