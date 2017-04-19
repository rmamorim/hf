# coding: utf-8


class Venda < ActiveRecord::Base

  has_many :promissorias
  has_many :compradors
  belongs_to :lote
  

  def to_label
    "venda: #{id}"
  end 


  def venda_valida?
    if [51,52,53,65,76].include? self.cod_status then
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




  def get_extrato data
  
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
      #v = p.get_valores Time.now
      v = p.get_valores data

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


  def testa
    processa_quitacao(30000,Time::local(2014,1,15).to_date)
  end


  def processa_quitacao valor, data
    valor_total = 0
    self.promissorias.each do|p|
      if p.nao_pago? then
        v = p.get_valores(data)
        puts p
        # puts data
        # puts v[:valor_vencimento]
        # puts v[:valor_contrato_corrigido]
        puts v[:valor_mora]
        puts v[:dias_atraso]
        valor_total += v[:valor_mora]
      end
    end

    puts "##########"
    puts "Valor total = #{valor_total}"
  end




  def get_status_promissorias

    # array
    # 0 - pagas
    # 1 - vincendas
    # 2 - atrasadas
    # 3 - > 90 dias
    # 4 - outros
    #
    # i_entrada
    # i_mensal
    # i_intermediaria
    # a_entrada
    # a_mensal
    # a_intermediaria
    # a_geral

    i = 0
    i_mensal = 0
    i_intermediaria = 0
    i_entrada = 0
    a_mensal = [0,0,0,0,0]
    a_entrada = [0,0,0,0,0]
    a_intermediaria = [0,0,0,0,0]
    a_geral = [0,0,0,0,0]

    promissorias = self.promissorias
    for p in promissorias do
      case p.cod_tipo_parcela

        ##
        ##  Entrada
        ##
        when 27, 67
          i_entrada += 1

          case p.get_status
            when :paga
              a_entrada[0] += 1
            when :nao_paga
              if p.dias_em_atraso > 0 then
                if p.dias_em_atraso > 90 then
                  a_entrada[3] += 1
                  a_entrada[2] += 1
                else
                  a_entrada[2] += 1
                end
              else
                a_entrada[1] += 1
              end
          end


        ##
        ##  Intermediaria
        ##
        when 28
          i_intermediaria += 1

          case p.get_status
            when :paga
              a_intermediaria[0] += 1
            when :nao_paga
              if p.dias_em_atraso > 0 then
                if p.dias_em_atraso > 90 then
                  a_intermediaria[3] += 1
                  a_intermediaria[2] += 1
                else
                  a_intermediaria[2] += 1
                end
              else
                a_intermediaria[1] += 1
              end
            when :liberada
              a_intermediaria[4] += 1
            when :desviada
              a_intermediaria[4] += 1
          end


        ##
        ##  Mensal, aluguel
        ##
        when 29, 75
          i_mensal += 1

          case p.get_status
            when :paga
              a_mensal[0] += 1
            when :nao_paga
              if p.dias_em_atraso > 0 then
                if p.dias_em_atraso > 90 then
                  a_mensal[3] += 1
                  a_mensal[2] += 1
                else
                  a_mensal[2] += 1
                end
              else
                a_mensal[1] += 1
              end

            ##
            ##  Outros
            ##
            when :liberada
              a_mensal[4] += 1
            when :desviada
              a_mensal[4] += 1
          end

      end
    end

    a_geral[0] = a_entrada[0] + a_mensal[0] + a_intermediaria[0]
    a_geral[1] = a_entrada[1] + a_mensal[1] + a_intermediaria[1]
    a_geral[2] = a_entrada[2] + a_mensal[2] + a_intermediaria[2]
    a_geral[3] = a_entrada[3] + a_mensal[3] + a_intermediaria[3]
    a_geral[4] = a_entrada[4] + a_mensal[4] + a_intermediaria[4]

    a = []
    a.push i_entrada
    a.push i_mensal
    a.push i_intermediaria
    a.push a_entrada
    a.push a_mensal
    a.push a_intermediaria
    a.push a_geral

    return a
  end



  def get_status
    # 0 - pagas
    # 1 - vincendas
    # 2 - atrasadas
    # 3 - > 90 dias
    # 4 - outros
    a = self.get_status_promissorias

    a_geral = a[6]

    status = :indefinido

    if a_geral[0] > 0 then
      status = :quitado
    end
    if a_geral[1] > 0 then
      status = :em_pagamento
    end
    if a_geral[2] > 0 then
      status = :inadimplente
    end
    if a_geral[3] > 0 then
      status = :inadimplente_grave
    end

    return status

  end



  def troca_dia_do_mes_promissorias novo_dia, promissoria_inicial, promissoria_final, tipo_promissoria = 29

    promissorias = Promissoria.where('venda_id = ? AND cod_tipo_parcela = ? AND num BETWEEN ? and ?', self.id, tipo_promissoria, promissoria_inicial, promissoria_final).order('num')

    promissorias.each do |p|
      d = p.data_vencimento
      novo_vencimento = Date.new(d.year,d.month,novo_dia)
      p.data_vencimento = novo_vencimento
      #puts novo_vencimento
      p.save
    end
  end


  def gera_boletos_intervalo_promissorias num_promissoria_inicial, num_promissoria_final, tipo_promissoria = 29

    promissorias = Promissoria.where('venda_id = ? AND cod_tipo_parcela = ? AND num BETWEEN ? and ?', self.id, tipo_promissoria, num_promissoria_inicial, num_promissoria_final).order('num')

    promissorias.each do |p|
      puts "#{p.num} - #{p.data_vencimento}"
      p.gera_boleto
    end
  end





end
