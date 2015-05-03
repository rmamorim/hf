# coding: utf-8


class Venda < ActiveRecord::Base

  has_many :promissorias
  has_many :compradors
  belongs_to :lote
  

  def to_label
    "venda: #{id}"
  end 


  def venda_valida?
    if [51,52,53,65].include? self.cod_status then
      return true
    else
      return false
    end
  end


  def get_cod_sacado
    cod_sacado = nil
    compradors.each do |comprador|
      cod_sacado = (!comprador.pessoa.cpf.nil?) ? Minha.new.cpf_to_codsac(comprador.pessoa.cpf) : nil
      break if !cod_sacado.nil?
    end
    return cod_sacado
  end


  def get_data_venda
    if !self.data_contrato.nil? then
      r = self.data_contrato
    else
      if !self.data_escritura.nil? then
        r = self.data_escritura
      else
        r = ''
      end
    end
    return r
  end


  def get_lote_nome
    area_nome = self.lote.area.nome
    lote_numero = self.lote.numero
    if area_nome == "A" and lote_numero == "1" then
      lote_numero = "123"
    end
    return format("%s-%s", area_nome, lote_numero)
  end


  def get_num_parcelas
    return self.promissorias.size
  end



  def insert_grupo_promissorias \
    num_primeira_intervalo, \
      num_ultima_intervalo, \
      qtd_intervalo, \
      correc_poup, \
      data_vencimento_prim, \
      cod_tipo_parcela, \
      frequencia, \
      valor_original

    for i in (num_primeira_intervalo..num_ultima_intervalo) do     
      p = Promissoria.new
      p.venda_id = self.id
      p.num = i
      p.num_total = qtd_intervalo
      p.correc_poup = correc_poup
      t = data_vencimento_prim.advance(:months => (i.to_i - num_primeira_intervalo.to_i) * frequencia.to_i)
      p.data_vencimento = Biblioteca::time2date(t)
      p.cod_status = 1 # Em pagamento
      p.cod_tipo_parcela = cod_tipo_parcela
      p.valor_original = valor_original

      p.save      
    end    
    return p    
  end



  def mora?
    ##
    ## Precisa detalhar este método para tratar caso onde a mora não é caracterizada por somples atrasos > 90 dias.
    ## Exemplo: vendas anteriores a da CA
    ##
    self.promissorias.sort{|a,b| a.data_vencimento <=> b.data_vencimento}.each do |p|
      if p.dias_em_atraso > 90 then
        return true
      end
    end
    return false
  end




  def get_extrato
  
    dados = {}
    soma = {}
    t = []
    linhas = []

    t.push "Vencimento"
    t.push "Pagamento"
    t.push "Dias de Atraso"
    t.push "Status"
    t.push "Parcela"
    t.push "Tipo de parcela"
    t.push "Valor"
    t.push "Pago"
    #t.push "Valor vencimento"
    t.push "Atualizado"
    t.push "Débito"
    #t.push "Valor contrato corrigido"
    #t.push "Diferença pagamento"
    #t.push "Comentário"
    #t.push ""

    soma[:entrada] = 0.0
    soma[:valor_pago] = 0.0
    soma[:saldo_devedor] = 0.0
    soma[:saldo_atrasada] = 0.0
    soma[:saldo_mora] = 0.0
    soma[:saldo_vincenda] = 0.0
    soma[:diferenca_pagamento] = 0.0
    soma[:pago_atualizado] = 0.0

    dados[:titulos] = t

    self.promissorias.sort{|a,b| a.data_vencimento <=> b.data_vencimento}.each do |p|
      v = p.get_valores Time.now

      idx_poupanca = idx_poupanca_contrato = 0
      data_venda = p.venda.get_data_venda


      #flag_pago = v[:dias_atraso] == 0 ? true : false
      flag_pago = false
      comentario = ''

      case p.get_situacao
      when :atrasada
        soma[:saldo_atrasada] += v[:valor_mora].to_i == 0 ? 0 : v[:valor_mora]
        situacao = 'Atrasada'
      when :mora
        soma[:saldo_mora] += v[:valor_mora].to_i == 0 ? 0 : v[:valor_mora]
        situacao = 'Vencida por mora'
      when :vincenda
        soma[:saldo_vincenda] += v[:valor_mora].to_i == 0 ? 0 : v[:valor_mora]
        situacao = 'Vicenda'
      when :paga
        flag_pago = true
        soma[:valor_pago] += flag_pago ? v[:valor_pago] : 0
        situacao = 'Paga'
        comentario = p.get_pagamento.comentarios
        idx_poupanca = Idxpoupanca::calcula_indice_entre_dates(p.data_vencimento, Time.now.to_date, self.tipo_correcao)
        idx_poupanca_contrato = Idxpoupanca::calcula_indice_entre_dates(data_venda, Time.now.to_date, self.tipo_correcao)
      end

      colunas = []


      ## Data de vencimento
      colunas.push Biblioteca::format_data(p.data_vencimento)
      ## Data de pagamento
      colunas.push flag_pago ? Biblioteca::format_data(v[:data_pagamento]) : ''
      ## Dias de atraso
      colunas.push << (v[:dias_atraso] > 0 ? v[:dias_atraso] : '')
      ## Status
      colunas.push situacao
      ## Promissoria
      colunas.push format('%s de %s', p.num, p.num_total)
      ## Tipo parcela
      colunas.push Codigo::get_status(p.cod_tipo_parcela)
      soma[:entrada] += (Codigo::get_status(p.cod_tipo_parcela) == 'Entrada') ? v[:valor_original] : 0

      ## Valor
      colunas.push Biblioteca::format_currency v[:valor_vencimento]
      ## Valor pago
      colunas.push flag_pago ? Biblioteca::format_currency(v[:valor_pago]) : ''
      ## Valor pago atualizado
      colunas.push << (idx_poupanca == 0 ? '' : Biblioteca::format_currency(idx_poupanca * v[:valor_vencimento]))
      soma[:pago_atualizado] += idx_poupanca == 0 ? 0 : (idx_poupanca * v[:valor_vencimento])
      ## Valor para pagamento
      colunas << (flag_pago ? '' : Biblioteca::format_currency(v[:valor_mora]))
      soma[:saldo_devedor] += flag_pago ? 0 : v[:valor_mora]
      ## Valor no vencimento
      #colunas.push v[:valor_vencimento]
      ## Valor Contrato Corrigido
      #colunas.push << (idx_poupanca_contrato == 0 ? '' : Biblioteca::format_currency(idx_poupanca_contrato * v[:valor_original]) )
      ## Diferença pagamento
      #colunas << Biblioteca::format_currency(v[:diferenca_pagamento])
      soma[:diferenca_pagamento] += (v[:diferenca_pagamento].nil? ? 0 : v[:diferenca_pagamento])
      ## Comentário
      #colunas.push comentario

      ## Soma parcial valor_pago
      #colunas.push soma[:valor_pago]

      linhas.push colunas
      
    end

    dados[:soma] = soma
    dados[:linhas] = linhas
    return dados

  end


  
end
