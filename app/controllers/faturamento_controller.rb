# coding: utf-8

class FaturamentoController < ApplicationController


  def myshow

    @year = params[:year]
    @month = params[:month]

    sql = <<sqltype
 select po.*
 from promissorias po
 left join boletos b
 on po.id = b.promissoria_id
 join pagamentos p
 on p.boleto_id = b.id
 and strftime('%Y-%m', p.data_pagamento) = '#{Time::local(@year,@month,1).to_s(:db)[0,7]}'
 join vendas v
 on v.id = po.venda_id
 join lotes l
 on l.id = v.lote_id
 join areas a
 on a.id = l.area_id
 join codigos c1
 on c1.id = po.cod_tipo_parcela
 join codigos c2
 on c2.id = v.cod_corretor
 join codigos c3
 on c3.id = po.cod_status
 left join codigos c4
 on c4.id = p.status
 where l.cod_vendedor_access = 1
 order by
 a.nome, l.numero, po.num
sqltype


    @valor = sql
    @lista = []
    lista = Promissoria.find_by_sql(sql)
    @total = 0.0
    lista.each do |p|

      area = p.venda.lote.area.nome
      lote = p.venda.lote.numero
      quadra = p.venda.lote.quadra
      parcela = p.num
      num_total = p.num_total
      tipo_promissoria = Codigo::get_status(p.cod_tipo_parcela)
      status_promissoria = Codigo::get_status(p.cod_status)
      data_vencimento = p.data_vencimento
      boleto_pago = p.get_boleto_pago
      pagamento = boleto_pago.pagamento
      data_pagamento = pagamento.data_pagamento
      valor_titulo = boleto_pago.valor_titulo
      valor_pago = pagamento.valor_pago

      a = []
      a.push(area)
      a.push(quadra)
      a.push(lote)      
      a.push(parcela)
      a.push(num_total)
      a.push(tipo_promissoria)
      a.push(status_promissoria)
      a.push(Biblioteca::format_data(data_vencimento))
      a.push(Biblioteca::format_data(data_pagamento))
      a.push(valor_titulo.to_s.sub(/[.]/,","))
      a.push(valor_pago.to_s.sub(/[.]/,","))

      @lista.push(a)
      @total = @total + valor_pago
    end
  end



  def index

  end

end
