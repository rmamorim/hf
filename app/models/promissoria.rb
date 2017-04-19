# coding: utf-8


class Promissoria < ActiveRecord::Base
  has_many :boletos
  belongs_to :venda




  def faz_pagamento_entrada_sem_boleto valor_pago
    data_pagamento = self.venda.get_data_venda
    valor_tarif_banco = valor_desconto = valor_juros = valor_multa = 0
    comentarios = 'Entrada paga no ato da escritura.'

    boleto = Boleto.new
    boleto.status = 40 # Sem Boleto
    boleto.valor_original = valor_pago
    boleto.valor_titulo = valor_pago
    boleto.promissoria_id = self.id
    boleto.save

    pagamento = Pagamento.new
    pagamento.boleto = boleto
    pagamento.status = 63 # Entrada - Status pagamento
    pagamento.valor_titulo = self.valor_original
    pagamento.valor_multa = valor_multa
    pagamento.valor_juros = valor_juros
    pagamento.valor_desconto = valor_desconto
    pagamento.valor_tarif_banco = valor_tarif_banco
    pagamento.valor_pago = valor_pago
    pagamento.data_pagamento = data_pagamento.to_s.strip
    pagamento.data_processamento = DateTime.now.strftime("%Y-%m-%d").to_s.strip
    pagamento.comentarios = comentarios
    pagamento.save

    self.cod_status = 63 # Entrada - Status Promissoria
    self.save
  end



  def to_s
    ## Qual a diferença para to_label ?

    "[ #{venda.lote.to_label}, #{num}, #{Codigo.get_status cod_tipo_parcela}, #{Biblioteca.format_data self.data_vencimento} ]"
  end


  def get_nome_lote
    return format("%s-%s", self.venda.lote.area.nome, self.venda.lote.numero)
  end


  def get_status
    status = :erro
    if self.dispensada?
      status = :liberada
    end
    if self.desviada?
      status = :desviada
    end
    if self.pago?
      status = :paga
    end
    if self.nao_pago?
      status = :nao_paga
    end
    if status == :erro
      puts ':erro! ' + self.cod_status.to_s
    end
    return status
  end


  def dispensada?
    if [42].include?(self.cod_status) then
      return true
    else
      return false
    end
  end


  def desviada?
    if [10, 17, 18, 19].include?(self.cod_status) then
      return true
    else
      return false
    end
  end


  def pago?
    if [12, 13, 15, 16, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 36, 37, 39, 63].include?(self.cod_status) then
      return true
    else
      return false
    end
  end


  def nao_pago?
    if [1, 14, 20, 26, 38].include?(self.cod_status) then
      return true
    else
      return false
    end
  end


  def dias_em_atraso
    if self.pago? then
      return 0
    else
      dias = ((Time.now - self.data_vencimento.to_time) / 86400).to_i
      if dias > 0 then
        return dias
      else
        return 0
      end
    end
  end


  def dias_em_atraso_data_base data_base
    if self.pago? then
      return 0
    else
      dias = ((data_base - self.data_vencimento.to_time) / 86400).to_i
      if dias > 0 then
        return dias
      else
        return 0
      end
    end
  end


  def get_data_boletos
    a = []
    i = 0
    self.boletos.each do |boleto|
      if i == 0 then
        a.push(boleto.data_emissao)
      else
        a.push("\n" + boleto.data_emissao.to_s)
      end
      i += 1
    end
    return a
  end


  def get_valor_boletos
    a = []
    i = 0
    self.boletos.each do |boleto|
      if i == 0 then
        a.push(boleto.valor_titulo)
      else
        a.push("\n" + boleto.valor_titulo.to_s)
      end
      i += 1
    end
    return a
  end





  def get_valores dt

    ###
    ###   Time está se tornando a data padrão
    ###   {Time::local(ano,mes,1).to_s(:db)[0,7]}
    ###
    ###   PENTELHO !!!
    ###   O BD Armazena o tipo Date, logo ESTE deverah ser o padrão!
    ###

    @valores = {}
    @diferenca_pag = 0
    @valor_data_corrigido = 0
    @valor_vencimento = 0
    @multa = @juros = @correcao_monetaria = 0
    @valor_data_mora = 0
    @dias_atraso = 0


    def quitacao_paga
      ###
      ###
      ###
    end


    def generica
      ###
      ###
      ###
    end


    def entrada_intermediaria_quitacao_paga
      self.boletos.each do |b|
        if !b.pagamento.nil? then
          @valores[:data_pagamento] = (b.pagamento).data_pagamento
          @valores[:valor_pago] = (b.pagamento).valor_pago.to_f + (b.pagamento).valor_tarif_banco.to_f
          if b.status == 40 then    # Pagamento sem boleto
            @dias_atraso = 0
          else
            @dias_atraso = (b.pagamento.data_pagamento - self.data_vencimento).to_i
          end

          if @dias_atraso > 0 then
            ## Calcula diferença pagamento
            @multa = @valor_vencimento.to_f * self.venda.multa.to_f / 100.0
            @juros = @valor_vencimento.to_f * (@dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
            @valor_data_mora = @valor_vencimento.to_f + @multa + @juros
            @diferenca_pag = (b.pagamento).valor_pago.to_f - @valor_data_mora.to_f
          end
        end
      end
    end


    def mensal_paga
      (self.boletos).each do |b|
        if !(b.pagamento.nil?) then
          @valores[:data_pagamento] = (b.pagamento).data_pagamento
          @valores[:valor_pago] = (b.pagamento).valor_pago.to_f + (b.pagamento).valor_tarif_banco.to_f
          if b.status == 40 then    # Pagamento sem boleto
            @dias_atraso = 0
          else
            @dias_atraso = (b.pagamento.data_pagamento - self.data_vencimento).to_i
          end

          if @dias_atraso > 0 then # Calcula diferença pagamento
            @multa = @valor_vencimento.to_f * self.venda.multa.to_f / 100.0
            @juros = @valor_vencimento.to_f * (@dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
            idx = Idxpoupanca::calcula_indice_entre_dates(self.data_vencimento, b.pagamento.data_pagamento, self.venda.tipo_correcao)
            @correcao_monetaria = (idx - 1) * @valor_vencimento
            @valor_data_mora = @valor_vencimento.to_f + @multa + @juros + @correcao_monetaria
            @diferenca_pag = (b.pagamento).valor_pago.to_f - @valor_data_mora.to_f
          end
        end
      end
    end


    dt = (dt.class == Time) ? dt.to_date : dt
    @dias_atraso = (dt - self.data_vencimento).to_i
    valor_original = self.valor_original

    (data = self.data_vencimento) if [27,28,67,75].include?(self.cod_tipo_parcela)  ## 27- entrada 28- intermediaria 67- quitação 75- aluguel
    (data = self.get_data_reajuste_promissoria_mensal) if [29,77].include?(self.cod_tipo_parcela)  ##  29- mensal  77- fracionamento     Analisar get_data_reajuste_promissoria_mensal
    correcao = calcula_correcao data
    @valor_vencimento = correcao[:valor_titulo]

    if !self.pago? then
        ##
        ##  Promissória nao paga

        if @dias_atraso > 0 then
          correcao = calcula_correcao dt
          @valor_data_corrigido = correcao[:valor_titulo]
          @multa = @valor_vencimento.to_f * self.venda.multa.to_f / 100.0
          @juros = @valor_vencimento.to_f * (@dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0

          idx = Idxpoupanca::calcula_indice_entre_dates(self.data_vencimento, dt, self.venda.tipo_correcao)
          @correcao_monetaria = (idx - 1) * @valor_vencimento
          @valor_data_mora = @valor_vencimento.to_f + @multa + @juros + @correcao_monetaria
        else
          @valor_data_corrigido = @valor_vencimento
          @multa = 0
          @juros = 0
          @valor_data_mora = @valor_vencimento
        end
    else
        entrada_intermediaria_quitacao_paga if [27,28,67,75].include?(self.cod_tipo_parcela)
        mensal_paga if [29,77].include?(self.cod_tipo_parcela)
    end


    @valores[:valor_original] = Biblioteca::arredonda_float valor_original, 2 # Valor original
    @valores[:valor_vencimento] = @valor_vencimento # Valor no vencimento, sem juros e multa
    @valores[:valor_contrato_corrigido] = @valor_data_corrigido # Valor na data dt, corrigido entre data_contrato e dt
    @valores[:valor_mora] = Biblioteca::arredonda_float @valor_data_mora, 2 # Valor na data dt, com juros e multa
    @valores[:juros] = Biblioteca::arredonda_float @juros, 2 # Valor de juros por não pagamento até a data dt
    @valores[:multa] = Biblioteca::arredonda_float @multa, 2 # Valor da multa por não pagamento até a data dt
    @valores[:correcao_monetaria] = Biblioteca::arredonda_float @correcao_monetaria, 2
    @valores[:dias_atraso] = @dias_atraso.to_i # Número de dias em atraso, até a data dt
    @valores[:diferenca_pagamento] = Biblioteca::arredonda_float @diferenca_pag, 2 # Diferença no valor pago, devido descontos ou nao pag de juros e/ou multas

    #puts "*********************"
    #puts "*********************"
    #puts "*********************"
    #puts " Data = #{dt}"
    #puts " promissoria_id = #{self.id}"
    #puts " valor_original = #{@valores[:valor_original]}"
    #puts " valor_vencimento = #{@valores[:valor_vencimento]}"
    #puts " valor_corrigido = #{@valores[:valor_contrato_corrigido]}"
    #puts " valor_mora = #{@valores[:valor_mora]}"
    #puts " juros = #{@valores[:juros]}"
    #puts " multa = #{@valores[:multa]}"
    #puts " correcao = #{@valores[:correcao_monetaria]}"
    #puts " dias_atraso = #{@valores[:dias_atraso]}"
    #puts " diferenca_pagamento = #{@valores[:diferenca_pagamento]}"
    #puts "*********************"
    #puts "*********************"
    #puts "*********************"

    return @valores
  end


  def get_valores_old dt

      ##
      ## Time está se tornando a data padrão
      ## {Time::local(ano,mes,1).to_s(:db)[0,7]}
      ##
      dt = (dt.class == Date) ? Biblioteca::date2time(dt) : dt
      dias_atraso = (dt - Biblioteca::date2time(self.data_vencimento)) / 86400
      valores = {}
      valor_original = self.valor_original

      ##  27-Entrada ou 28-Intermediaria
      ##
      if (self.cod_tipo_parcela == 27) or (self.cod_tipo_parcela == 28)
      then
        correcao = calcula_correcao self.data_vencimento
        valor_vencimento = correcao[:valor_titulo]
        diferenca_pag = 0

        if self.pago? then
          ##
          ##  Promissória paga
          ##
          valor_data_corrigido = 0
          multa = 0
          juros = 0
          valor_data_mora = 0
          dias_atraso = 0
          self.boletos.each do |b|
            if !b.pagamento.nil? then
              valores[:data_pagamento] = (b.pagamento).data_pagamento
              valores[:valor_pago] = (b.pagamento).valor_pago.to_f
              dias_atraso = (Biblioteca::date2time((b.pagamento).data_pagamento) - Biblioteca::date2time(self.data_vencimento)) / 86400

              if dias_atraso > 0 then # Calcula diferença pagamento
                multa = valor_vencimento.to_f * self.venda.multa.to_f / 100.0
                juros = valor_vencimento.to_f * (dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
                valor_data_mora = valor_vencimento.to_f + multa + juros
                diferenca_pag = (b.pagamento).valor_pago.to_f - valor_data_mora.to_f
              end

            end
          end
        else
          ##
          ##  Promissória nao paga
          ##
          if dias_atraso > 0 then
            correcao = calcula_correcao dt
            valor_data_corrigido = correcao[:valor_titulo]
            multa = valor_vencimento.to_f * self.venda.multa.to_f / 100.0
            juros = valor_vencimento.to_f * (dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
            valor_data_mora = valor_vencimento.to_f + multa + juros
          else
            valor_data_corrigido = valor_vencimento
            multa = 0
            juros = 0
            valor_data_mora = valor_vencimento
          end
        end
      end

      ##  29 - Mensal
      ##
      if self.cod_tipo_parcela == 29
      then
  ##
  ## Analisar
        primeira_data_periodo = self.get_data_reajuste_promissoria_mensal
        correcao = calcula_correcao primeira_data_periodo
        valor_vencimento = correcao[:valor_titulo]

        if self.pago? then
          ##
          ##  Promissória paga
          ##
          valor_data_corrigido = 0
          multa = 0
          juros = 0
          valor_data_mora = 0
          dias_atraso = 0
          self.boletos.each do |b|
            if !b.pagamento.nil? then
              valores[:data_pagamento] = (b.pagamento).data_pagamento
              valores[:valor_pago] = (b.pagamento).valor_pago.to_f
              if b.status == 40 then
                # Pagamento sem boleto
                dias_atraso = 0
              else
                dias_atraso = (Biblioteca::date2time((b.pagamento).data_pagamento) - Biblioteca::date2time(self.data_vencimento)) / 86400
              end

              if dias_atraso > 0 then # Calcula diferença pagamento
                multa = valor_vencimento.to_f * self.venda.multa.to_f / 100.0
                juros = valor_vencimento.to_f * (dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
                valor_data_mora = valor_vencimento.to_f + multa + juros
                diferenca_pag = (b.pagamento).valor_pago.to_f - valor_data_mora.to_f
              end

            end
          end
        else
          ##
          ##  Promissória nao paga
          ##
          if dias_atraso > 0 then
            correcao = calcula_correcao dt
            valor_data_corrigido = correcao[:valor_titulo]
            multa = valor_vencimento.to_f * self.venda.multa.to_f / 100.0
            juros = valor_vencimento.to_f * (dias_atraso.to_f / 30.0) * self.venda.juros.to_f / 100.0
            valor_data_mora = valor_vencimento.to_f + multa + juros
          else
            valor_data_corrigido = valor_vencimento
            multa = 0
            juros = 0
            valor_data_mora = valor_vencimento
          end
        end
      end


      valores[:valor_original] = valor_original # Valor original
      valores[:valor_vencimento] = valor_vencimento # Valor no vencimento, sem juros e multa
      valores[:valor_contrato_corrigido] = valor_data_corrigido # Valor na data dt, corrigido entre data_contrato e dt
      valores[:valor_mora] = valor_data_mora # Valor na data dt, com juros e multa
      valores[:juros] = juros # Valor de juros por não pagamento até a data dt
      valores[:multa] = multa # Valor da multa por não pagamento até a data dt
      valores[:dias_atraso] = dias_atraso.to_i # Número de dias em atraso, até a data dt
      valores[:diferenca_pagamento] = diferenca_pag # Diferença no valor pago, devido descontos ou nao pag de juros e/ou multas


      #puts "*********************"
      #puts "*********************"
      #puts "*********************"
      #puts " promissoria_id = #{self.id}"
      #puts " valor_original = #{valores[:valor_original]}"
      #puts " valor_vencimento = #{valores[:valor_vencimento]}"
      #puts " valor_corrigido = #{valores[:valor_corrigido]}"
      #puts " valor_mora = #{valores[:valor_mora]}"
      #puts " juros = #{valores[:juros]}"
      #puts " multa = #{valores[:multa]}"
      #puts " dias_atraso = #{valores[:dias_atraso]}"
      #puts " diferenca_pagamento = #{valores[:diferenca_pagamento]}"
      #puts "*********************"
      #puts "*********************"
      #puts "*********************"


      return valores
    end



  def get_direfenca_pagamento
    if !self.pago? then
      return 0
    end
  end


  def get_via
    self.boletos.size + 1
  end



  def gera_seu_numero
    ## via = self.get_via
    ## seu_numero = format("%s-%s/%s", self.venda.get_lote_nome, self.num, self.num_total)
    ## seu_numero = (via > 1) ? format("%s.%s", seu_numero, via) : seu_numero

    #msg_via = get_via > 1 ? format(".%i", get_via.to_i) : ""
    #seu_numero = format("%s-%s/%s%s", self.venda.lote.to_label, self.num, self.num_total, msg_via).strip

    area = self.venda.lote.area.nome.strip
    case area.strip
      when 'A'
        loteamento = '01'
      when 'B'
        loteamento = '02'
      when 'J'
        loteamento = '03'
      when 'M'
        loteamento = '04'
      when 'C'
        loteamento = '05'
      when 'DMJ'
        loteamento = '06'
      when 'DUS'
        loteamento = '07'
      when 'COT'
        loteamento = '08'
      else
        loteamento = '00'
    end

    s_quadra = self.venda.lote.quadra.to_s.strip
    case s_quadra
      when 'A', 'B1'
        quadra = '1'
      when 'B', 'B2'
        quadra = '2'
      when 'C', 'B3'
        quadra = '3'
      when 'D', 'B4'
        quadra = '4'
      when 'E', 'B5'
        quadra = '5'
      when 'F', 'B6'
        quadra = '6'
      when 'G', 'B7'
        quadra = '7'
      when 'H', 'B8'
        quadra = '8'
      when 'I', 'B9'
        quadra = '8'

      else
        quadra = '0'
    end

    s_lote = self.venda.lote.numero.to_s.strip
    lote = s_lote.rjust(3,'0')

    case self.cod_tipo_parcela
      when 27
        tipo_parcela = '1'
      when 28
        tipo_parcela = '2'
      when 29
        tipo_parcela = '3'
      when 67
        tipo_parcela = '4'
      when 75
        tipo_parcela = '5'
      when 77
        tipo_parcela = '6'

      else
        tipo_parcela = '0'
    end

    s_num_parcela = self.num.to_s.strip
    num_parcela = s_num_parcela.rjust(3,'0')

    via = get_via.to_s.strip[-1..-1]

    seu_numero = loteamento + quadra + lote + tipo_parcela + num_parcela + via



  end



  def gera_mensagem1
    mensagem1 = format("### Lote %s ###", self.venda.lote.to_label)
  end


  def gera_mensagem2
    ##
    ## Identificação da parcela
    ##
    if cod_tipo_parcela == 29 then
      # Mensal
      tipo_parcela = 'mensal'
    end
    if cod_tipo_parcela == 28 then
      # Intermediaria
      tipo_parcela = 'interm.'
    end
    if cod_tipo_parcela == 27 then
      # Entrada
      tipo_parcela = 'entrada'
    end
    msg_via = get_via > 1 ? format(" %ia via", get_via.to_i) : ""
    mensagem2 = format("%s : NP %s de %s %s", self.venda.lote.to_label, self.num, self.num_total, msg_via).strip
  end



  def get_situacao
    if self.pago?
      return :paga
    else
      if self.dias_em_atraso > 0 then
        return :atrasada
      else
        if self.venda.mora? then
          return :mora
        else
          return :vincenda
        end
      end
    end
  end


  def get_boleto_pago
    self.boletos.each do |boleto|
      if !boleto.pagamento.nil? then
        return boleto
      end
    end
    return nil
  end


  def get_tipo_boleto
    corretor = self.venda.cod_corretor
    dono = self.venda.lote.cod_vendedor_access

    case corretor
      when 8 # Corretor = Cristina Amaral
        r = 2
      when 10 # Corretor = Hansa Fly e/ou outros
        r = 0
        if dono == 1 then # Proprietario = Hansa Fly
          r = 1
        end
        if dono == 2 then # Proprietario = LSA
          r = 3
        end
      else
        r = 0
        if dono == 1 then # Proprietario = Hansa Fly
          r = 1
        end
        if dono == 2 then # Proprietario = LSA
          r = 3
        end
    end
    return r
  end


  def get_pagamento
    self.boletos.each do |boleto|
      if !boleto.pagamento.nil? then
        return boleto.pagamento
      end
    end
    return nil
  end


  def get_valor_pago
    self.boletos.each do |boleto|
      if !boleto.pagamento.nil? then
        return (boleto.pagamento).valor_pago.to_f
        exit
      end
    end
  end


  def Promissoria.proc_csv_gera_boletos arq
    f = File.new("/home/ricardo/hansafly/BDs/ruby/inserts/insert_titulos.sql", "w")
    CSV::Reader.parse(File.open("dados_csv/"+ arq, 'rb')) do |row|
      #      puts row
      if row[0] != "lote"
        p row
        promissoria = Promissoria::get_promissoria(row[0], row[1])

        #tipo_boleto = promissoria.get_tipo_boleto
        tipo_boleto = row[2].to_i
        data_vencimento = datacsv_to_datasql(row[3].to_s)
        data_emissao = datacsv_to_datasql(row[4].to_s)
        boleto = promissoria.gera_boleto(data_emissao, data_vencimento, tipo_boleto)
        s = boleto.gera_titulo
        f.puts s
      end
    end
    f.close
  end


  def Promissoria.proc_csv_pagamento_promissorias arq
    CSV::Reader.parse(File.open("dados_csv/"+ arq, 'rb')) do |row|
      #break if !row[0].is_null && row[0].data == 'stop'
      if row[0] != "lote"
        p row
        promissoria = Promissoria::get_promissoria(row[0], row[1])
        if !promissoria.pago?
          boleto = promissoria.gera_boleto(DateTime.now.strftime("%Y-%m-%d"), 3)
          boleto.pagamento row[2], row[3], row[4], row[5], row[6], '0.0', row[7], datacsv_to_datasql(row[8].to_s), row[9]
        else
          puts "   >>> Promissoria jah paga!"
        end
      end
    end
  end


  def get_data_compra
    return self.venda.get_data_venda

    #    if !self.venda.data_escritura.nil? then
    #      r = self.venda.data_escritura
    #    end
    #    if !self.venda.data_contrato.nil? then
    #      r = self.venda.data_contrato
    #    end
    #    return r
  end


  def get_idx_poupanca_intermediaria data_vencimento, tipo
    return Idxpoupanca::calcula_indice_entre_dates(self.venda.get_data_venda, data_vencimento, tipo)
  end




  def get_data_reajuste_promissoria_mensal
    periodo = self.venda.periodo_correcao_parcela_mensal
    primeira = self.venda.primeira_parcela_atualizar

    ##num_promissoria_reajuste = (((self.num.to_i - 1)/ periodo.to_i) * periodo.to_i) + 1
    aux = self.num.to_i - 1 + primeira.to_i
    aux = (((aux.to_i - 1)/ periodo.to_i) * periodo.to_i) + 1
    num_promissoria_reajuste = (aux.to_i + 1 - primeira.to_i) > 0 ? (aux.to_i + 1 - primeira.to_i) : primeira.to_i


    venda_id = self.venda_id
    num_total = self.num_total
    num = num_promissoria_reajuste

    p = Promissoria.first(:conditions => format("(venda_id = %d and num = %d and num_total = %d)", venda_id, num, num_total))

    return p.data_vencimento
  end




  def get_idx_poupanca_mensal data_base, tipo
    return Idxpoupanca::calcula_indice_entre_dates(self.venda.get_data_venda, data_base, tipo)
  end


  def get_idx_poupanca_inicio

    periodo = self.venda.periodo_correcao_parcela_mensal

    messes_correc = self.num.to_i * periodo
    dt_fim = format("'%s'", self.data_vencimento.to_s)
    idxs = Idxpoupanca.where("mes between '1900-01-01' and " + dt_fim).order("mes DESC")
    idx = 1
    cont = 1
    idxs.each do |i|
      if cont <= messes_correc then
        idx = idx * ((i.indice.to_f / 100) + 1)
        cont += 1
      end
    end
    return idx

  end


  #  def get_idx_poupanca
  #    messes_correc = ((self.num.to_i - 1) / 12) * 12
  #    parcela_ref_correc = messes_correc + 1
  #
  #    p_reajuste = Promissoria.find(:first,
  #      :conditions => format("venda_id = %s and num_total = %s and num = %s", self.venda_id, self.num_total, parcela_ref_correc))
  #
  #    ano = get_ano_databd(self.data_vencimento.to_s)
  #    mes = get_mes_databd(self.data_vencimento.to_s)
  #
  #    #dt_fim = format("'%s-%s-31'", ano, mes)
  #    #puts dt_fim
  #    dt_fim = format("'%s'",p_reajuste.data_vencimento.to_s)
  #    #puts dt_fim
  #
  #    idxs = Idxpoupanca.find(:all,
  #      :conditions => "mes between '1900-01-01' and " + dt_fim,
  #      :order => "mes DESC"
  #    )
  #    idx = 1
  #    cont = 1
  #    idxs.each do |i|
  #      if cont <= messes_correc then
  #        idx = idx * ((i.indice.to_f / 100) + 1)
  #        #        printf "mes = %s\n", i.mes
  #        #        printf "indice = %s\n", i.indice
  #        #        printf "idx = %s\n", idx
  #        #        printf "cont = %s\n", cont
  #        #        printf "---------\n"
  #        cont += 1
  #      end
  #    end
  #    return idx
  #  end


  def get_idx_poupanca
    messes_correc = ((self.num.to_i - 1) / 12) * 12
    parcela_ref_correc = messes_correc + 1

    p_reajuste = Promissoria.find(:first,
                                  :conditions => format("venda_id = %s and num_total = %s and num = %s", self.venda_id, self.num_total, parcela_ref_correc))

    ano = Biblioteca::get_ano_databd(self.data_vencimento.to_s)
    mes = Biblioteca::get_mes_databd(self.data_vencimento.to_s)

    #dt_fim = format("'%s-%s-31'", ano, mes)
    #puts dt_fim
    dt_fim = format("'%s'", p_reajuste.data_vencimento.to_s)
    #puts dt_fim

    idxs = Idxpoupanca.find(:all,
                            :conditions => "mes between '1900-01-01' and " + dt_fim,
                            :order => "mes DESC"
    )
    idx = 1
    cont = 1
    idxs.each do |i|
      if cont <= messes_correc then
        idx = idx * ((i.indice.to_f / 100) + 1)
        #        printf "mes = %s\n", i.mes
        #        printf "indice = %s\n", i.indice
        #        printf "idx = %s\n", idx
        #        printf "cont = %s\n", cont
        #        printf "---------\n"
        cont += 1
      end
    end
    return idx
  end


  #  def get_valor_promissoria_dt_vencimento
  #    perc_poup = self.get_idx_poupanca
  #    return perc_poup.to_f * self.valor_original.to_f
  #  end


  def get_valor_data_vencimento_original


    puts self.class
    puts self.id
    puts self.to_s


    if self.correc_poup then
      boleto = Boleto.new
      data_primeira_periodo = self.get_data_reajuste_promissoria_mensal
      set_correcao boleto, Biblioteca::date2time(data_primeira_periodo)
      return boleto.valor_titulo
    else
      return self.valor_original
    end

  end




##
##  2.0 Nova
##
  def calcula_correcao data_base
    ##
    ## Calcula correção monetária contratual (não é correção/multa/juros por atraso!)
    ##

    r = {:perc_poup => 1, :valor_titulo => self.valor_original, :atualizacao => 0}

    if self.correc_poup then
      ##
      ## Tem correcao
      ##
      case self.cod_tipo_parcela
        when 28
          ## Intermediaria
          ##
          r[:perc_poup] = self.get_idx_poupanca_intermediaria(data_base, self.venda.tipo_correcao)
        when 29
          ## Mensal
          ##
          ##(r[:perc_poup] = self.get_idx_poupanca_mensal(data_base, self.venda.tipo_correcao)) if (data_base.beginning_of_month >= (self.venda.get_data_venda + (self.venda.periodo_correcao_parcela_mensal+1).month).beginning_of_month)

          if (self.num >= self.venda.primeira_parcela_atualizar)
            r[:perc_poup] = self.get_idx_poupanca_mensal(data_base, self.venda.tipo_correcao)
          end

      end
      r[:valor_titulo] = Biblioteca::arredonda_float(r[:perc_poup].to_f * self.valor_original.to_f, 2)
      r[:atualizacao] = Biblioteca::arredonda_float(r[:valor_titulo].to_f - self.valor_original.to_f, 2)
    end

    return r
  end


##
##  1.0 Atual
##
  def set_correcao boleto, data_base
    ##
    ## Aplica correção monetária contratual (não é correção/multa/juros por atraso!)
    ##

    if self.correc_poup then
      ##
      ## Tem correcao
      ##
      case self.cod_tipo_parcela
        when 28
          ##
          ## Intermediaria
          ##
          boleto.perc_poup = self.get_idx_poupanca_intermediaria(data_base)
        when 29
          ##
          ## Mensal
          ##
          boleto.perc_poup = self.get_idx_poupanca_mensal(data_base)
      end
      boleto.valor_titulo = Biblioteca::arredonda_float(boleto.perc_poup.to_f * self.valor_original.to_f, 2)
      boleto.atualizacao = Biblioteca::arredonda_float(boleto.valor_titulo.to_f - self.valor_original.to_f, 2)

    else
      ##
      ## Nao tem correcao
      ##
      boleto.perc_poup = 1
      boleto.valor_titulo = self.valor_original
      boleto.atualizacao = 0
    end
  end


  def eh_para_imprimir_boleto?
    #
    # Testa se: nao esta pago + (mensal ou intermediaria) + nao tem boletos + (promissoria nao LSA)
    #
    # Retirado: #        and self.boletos.size == 0 \

    if !self.pago? \
        and (self.cod_tipo_parcela == 28 or self.cod_tipo_parcela == 29) \
        and self.get_tipo_boleto != 3 then
      return true
    else
      return false
    end
  end


  def promissorias_to_promissorias_atrasadas p
    # p = array de promissorias

    promissorias_atrasadas = []
    ## retorna array de vendas a partir do array de promissorias
    lista_vendas_id = p.map { |e| e.venda.id }.uniq.join(",")

    ## Promissorias anteriores a 1 mes atras
    cond = <<SQL_TYPE
    venda_id IN (#{lista_vendas_id})
    AND (strftime('%Y-%m-%d', data_vencimento) < '#{Time.now.months_ago(1).to_s(:db)[0, 10]}')
SQL_TYPE

    promissorias = Promissoria.where(cond)
    promissorias.each do |prom|
      promissorias_atrasadas << prom if !prom.pago?
    end

    return promissorias_atrasadas

  end


###
###
### 25/04/2012
###
###
  def gera_boletos_parcelas_atrasadas lote_id

    b = []
    lote = Lote.find(lote_id)
    venda = lote.get_venda

    promissorias_atrasadas = []
    lista_vendas_id = venda.id

    ## Promissorias anteriores a 1 mes atras
    cond = <<SQL_TYPE
    venda_id IN (#{lista_vendas_id})
    AND (strftime('%Y-%m-%d', data_vencimento) < '#{Time.now.months_ago(1).to_s(:db)[0, 10]}')
SQL_TYPE

    promissorias = Promissoria.where(cond)
    promissorias.each do |prom|
      promissorias_atrasadas << prom if !prom.pago?
    end

    promissorias_atrasadas.each do |p|
      options = {}
      options[:data_vencimento] = (Time.now + 14.day).to_date
      b << (p.gera_boleto_vencido options)
    end

    return b
  end



###
###
### 31/05/2011 - Gera boletos iniciais de lote recem vendido.
###              Verificar data primeira parcela + 11 meses.
###
  def gera_boletos_iniciais lote_id

    lote = Lote.find(lote_id)
    venda = lote.get_venda
    data_venda = venda.data_escritura
    data_venda = data_venda.nil? ? venda.data_contrato : data_venda

    #dt = (data_venda + 1.year + 1.month - 1.day).to_s(:db)
    dt = (data_venda + (venda.primeira_parcela_atualizar-1).month + 15.day).to_s(:db)

    sql = <<SQL_TYPE
    select *
    from promissorias p
    where p.venda_id = #{venda.id}
    and p.data_vencimento < '#{dt}'
    and p.data_vencimento <> '#{(data_venda).to_s(:db)}'
    order by p.data_vencimento
SQL_TYPE

    flag = true
    a = []
    promissorias = Promissoria.find_by_sql(sql)
    promissorias.each do |p|
      ##
      ## Evitar correcao monetaria para parcelas mensais
      ## CORRIGIR: nao calcula correcao entre dt_venda e dt_primeira_mensal para intermediarias
      if !p.pago? then
        if flag and (p.cod_tipo_parcela == 29) then
          venda.data_escritura = p.data_vencimento
          venda.save
          flag = false
        end

        tipo_boleto = 46 #normal
        b = p.gera_boletob tipo_boleto, "", ""
        a << "#{p.num} : #{p.data_vencimento} ** valor inicial = #{p.valor_original} * valor boleto = #{b.valor_titulo}  ***  (#{b.cod_sac})"
      end
    end

    venda.data_escritura = data_venda
    venda.save

    return a
  end


  def cond_promissoria_para_reajustar ano, mes
    ##
    ## A atual condição verifica se (cod_tipo_parcela = mensal and (num % 12 = 1)) or (cod_tipo_parcela = intermediaria)
    ## Deve ser refeito pois nao esta generico. Não atende ao caso de reajuste trimestral.
    ##
    cond = <<SQL_TYPE
  (strftime('%Y-%m', data_vencimento) = '#{Time::local(ano,mes,1).to_s(:db)[0,7]}')
  and ((cod_tipo_parcela = 29 and (num % 12 = 1)) or (cod_tipo_parcela = 28))
SQL_TYPE

    return cond
  end


#SELECT
#*
#FROM promissorias p
#JOIN vendas v ON p.venda_id = v.id
#WHERE (strftime('%Y-%m', data_vencimento) = '2012-04')
#AND ((cod_tipo_parcela = 29 and (p.num % v.periodo_correcao_parcela_mensal = 1)) or (cod_tipo_parcela = 28))




###
###
### Nova versão - ATUAL
###
###
  def gera_boletos_mes_new ano, mes

    promissorias_mes = []

    #cond = cond_promissoria_para_reajustar ano, mes
    #promissorias = Promissoria.where(ond)

    promissorias = Promissoria.select('p.*'). \
      where("(strftime('%Y-%m', data_vencimento) = '#{Time::local(ano,mes,1).to_s(:db)[0,7]}') \
            and ((cod_tipo_parcela = 29 and ((p.num >= v.primeira_parcela_atualizar) and (p.num % v.periodo_correcao_parcela_mensal = (v.primeira_parcela_atualizar % v.periodo_correcao_parcela_mensal)))) or (cod_tipo_parcela = 28))"). \
      joins("as p join vendas as v on p.venda_id = v.id")

    promissorias.each do |p|
      ##  Parcela Mensal
      ##  Se a promissoria for de uma parcela mensal, ira buscar as outras promissorias do periodo.

      if p.cod_tipo_parcela == 29 then  # Parcela mensal

        periodo = p.venda.periodo_correcao_parcela_mensal
        if (periodo > 1) then

          cond = <<SQL_TYPE
      venda_id = #{p.venda_id}
      and cod_tipo_parcela = 29
      and num_total = #{p.num_total}
      and (num between #{p.num + 1} and #{p.num + periodo - 1} )
SQL_TYPE
          proms_intervalo = Promissoria.where(cond)
          proms_intervalo.each do |p_intervalo|
            promissorias_mes.push(p_intervalo) if p_intervalo.eh_para_imprimir_boleto?
          end
        end
      end
      promissorias_mes.push(p) if p.eh_para_imprimir_boleto?
    end


    ##
    ## Acrescenta as promissorias atrasadas
#    conjunto_promissorias = promissorias_mes + promissorias_to_promissorias_atrasadas(promissorias_mes)
    conjunto_promissorias = promissorias_mes


    ##
    ## Gera boletos para as promissórias

    boletos = []
    ## Ordena promissorias - não está correto!!!
    prom_ordenadas = conjunto_promissorias.sort_by { |a| [a.venda.lote.numero, a.data_vencimento] }

    prom_ordenadas.each do |p|
      ### - Por que precisa colocar options :vincendo ?
      options = {}
      options[:tipo_boleto] = :vincendo
      boletos << p.gera_boleto(options)
    end

    return boletos

  end






  ###
  ###
  ### Versão 2
  ###
  ###
  def gera_boletos_mesb ano, mes
    lotes = {} # Promissorias do lote
    num_final = {} # Ultima promissoria mensal do lote no periodo de 12 meses
    dados = []

    cond = "data_vencimento >= '#{Time::local(ano, mes, 1).to_s(:db)}'"
    promissorias = Promissoria.find(:all, :conditions => cond)
    dados.push(format("Número de promissórias a receber = %s\n", promissorias.size))
    puts format("Número de promissórias a receber = %s\n", promissorias.size)

    i = 0
    promissorias.each do |promissoria|
      if i == 2300 then
        #exit
      else
        #puts "******[ #{i+1} promissoria.id = #{promissoria.id} ]*******"
        i = i + 1
      end

      lote = promissoria.venda.lote

      if promissoria.eh_para_imprimir_boleto? then

        case promissoria.cod_tipo_parcela
          ##
          ##  Intermediaria
          ##
          when 28
            ## testa para ver se a intermediaria esta no periodo
            if Biblioteca::get_mes_databd(promissoria.data_vencimento.to_s) == mes.to_i and Biblioteca::get_ano_databd(promissoria.data_vencimento.to_s) == ano.to_i then
              if lote[lote].nil? then
                a = []
                a.push(promissoria)
                lotes[lote] = a
              else
                lotes[lote].push(promissoria)
              end
            end

          ##
          ##  Mensal
          ##
          when 29
            # Encontra ultima promissoria do periodo
            if num_final[lote].nil? then
              cond = "(cod_tipo_parcela = 29 AND venda_id = #{promissoria.venda_id} AND strftime('%Y-%m',data_vencimento) = '#{Time::local(ano, mes, 1).to_s(:db)[0, 7]}')"
              p_atual = Promissoria.find(:first, :conditions => cond)
              num_final[lote] = ((((p_atual.num - 1) / 12) + 1) * 12)
            end
            # Testa de a promissoria mensal está no intervalo de 12

            if promissoria.num <= num_final[lote] then
              if lotes[lote].nil? then
                a = []
                a.push(promissoria)
                lotes[lote] = a
              else
                lotes[lote].push(promissoria)
              end
            end
        end

      else
        ##
        ## Promissoria jah esta paga.
        ##

        #printf "(N)lote = %s-%s (id:%s)\n", lote.area.nome, lote.numero, lote.id
        #printf "   cod_tipo_parcela = %s\n", promissoria.cod_tipo_parcela
        #printf "   num de boletos = %s\n", promissoria.boletos.size
        #printf "   tipo de boleto = %s\n", promissoria.get_tipo_boleto
        #printf "----\n"

      end #if
    end #do

    puts ">>>"
    puts ">>>>>"
    puts ">>>>>> INICIO DE GERA BOLETOS"

    ##
    ##  Gera boletos
    ##
    cont_boletos = 0
    lotes.sort_by { |key, value| key.id }.each { |key, value|
      dados.push(format("--------------------------------------\n"))
      puts "--------------------------------------"
      dados.push(format("\n"))
      dados.push(format(">>> lote = %s-%s \n", key.area.nome, key.numero))
      puts ">>> lote = #{key.area.nome}-#{key.numero}"

      value.each do |p|
        tipo_boleto = 46 #normal
        b = p.gera_boletob tipo_boleto, "", ""
        dados.push(format("     boleto: %s/%s - %s    - %s\n", p.num, p.num_total, p.data_vencimento, Biblioteca::format_currency(b.valor_titulo)))
        puts format("     boleto: %s/%s - %s    - %s\n", p.num, p.num_total, p.data_vencimento, Biblioteca::format_currency(b.valor_titulo))
        cont_boletos = cont_boletos + 1
      end
    }

    dados.push(format("#################\n"))
    dados.push(format("#################\n\n"))
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    dados.push(format("numero de lotes = %s\n", lotes.size))
    puts format("numero de lotes = %s\n", lotes.size)
    dados.push(format("numero de boletos = %s\n", cont_boletos))
    puts format("numero de boletos = %s\n", cont_boletos)

    return dados
  end


  ###
  ###
  ### Versão 1 - antiga
  ###
  ###
  def Promissoria.gera_boletos_mes ano, mes
    f = File.new(format("/home/ricardo/hansafly/BDs/ruby/inserts/insert_titulos_%s-%s.sql", ano, mes), "w")
    promissorias = self.find(:all,
                             :conditions => format("year (data_vencimento) = %s and month (data_vencimento) = %s", ano, mes))

    i1 = i2 = i3 = i4 = 0
    promissorias.each do |promissoria|
      tipo_boleto = promissoria.get_tipo_boleto
      if !promissoria.pago? \
          and (tipo_boleto >= 1 and tipo_boleto <= 2) \
          and (promissoria.boletos.size == 0) then
        printf "   lote = %s   -->  tipo = %s   --> data_vencimento = %s \n", promissoria.get_nome_lote, promissoria.get_tipo_boleto, get_dia_databd(promissoria.data_vencimento.to_s)
        boleto = promissoria.gera_boleto("", tipo_boleto)
        s = boleto.gera_titulo
        f.puts s

        if tipo_boleto == 1 then
          i1 += 1
        end
        if tipo_boleto == 2 then
          i2 += 1
        end
      else
        if tipo_boleto == 3 then
          i3 += 1
          printf "(LSA)  --->> lote = %s   -->  tipo = %s   --> data_vencimento = %s \n", promissoria.get_nome_lote, promissoria.get_tipo_boleto, get_dia_databd(promissoria.data_vencimento.to_s)
        else
          i4 += 1
          printf "(EMITIDO)  --->> lote = %s   -->  tipo = %s   --> data_vencimento = %s \n", promissoria.get_nome_lote, promissoria.get_tipo_boleto, get_dia_databd(promissoria.data_vencimento.to_s)
        end

      end
    end
    f.close
    puts
    printf "Qtd tipo 1 = %s\n", i1
    printf "Qtd tipo 2 = %s\n", i2
    printf "Qtd LSA = %s\n", i3
    printf "Qtd Já emitidos = %s\n", i4
    printf "Total de boletos = %s\n", i1 + i2 + i3 + i4
  end


  def testa_boletos_mes ano, mes
    f = File.new(format("/home/ricardo/insert_titulos_%s-%s.sql", ano, mes), "w")
    promissorias = Promissoria.find(:all,
                                    :conditions => format("year (data_vencimento) = %s and month (data_vencimento) = %s", ano, mes))

    i = 0
    promissorias.each do |promissoria|
      tipo_boleto = promissoria.get_tipo_boleto
      if !promissoria.pago? \
          and (tipo_boleto == 2) \
          and (promissoria.boletos.size == 0) \
          and (Biblioteca::get_dia_databd(promissoria.data_vencimento.to_s).to_i <= 10) then
        printf "lote = %s   -->  tipo = %s   --> data_vencimento = %s \n", \
          promissoria.get_nome_lote, \
          promissoria.get_tipo_boleto, \
          Biblioteca::get_dia_databd(promissoria.data_vencimento.to_s)

        promissoria.get_nome_lote

        #boleto = promissoria.gera_boleto("", tipo_boleto)
        #s = boleto.gera_titulo
        #f.puts s
        i += 1
      end
    end
    f.close
    puts
    printf "Total de boletos = %s\n", i
  end




  ##
  ## Versão 3 - nova
  ##
  ## tipo_boleto
  ## 46 - normal
  ## 47 - atrasado
  ## 48 - prorrogado
  ## 49 - antigo
  ## 50 - sem boleto
  ##
  def gera_boleto_completo \
    tipo_boleto, \
    data_vencimento, \
    data_base

    if ![46, 47, 48, 49, 50].include?(tipo_boleto) then
      puts ">>> ERRO: tipo de boleto inválido!"
      return
    end

    boleto = Boleto.new()
    boleto.promissoria_id = self.id
    boleto.status = 38 # Boleto não pago
    boleto.data_emissao = Time.now.to_date
    boleto.valor_original = self.valor_original
    boleto.data_vencimento = data_vencimento.to_date
    data_base = data_base.to_date
    dias_permitido_receber = 90

    boleto.save
    return boleto

  end





  ##
  ##    Versão 3 - nova
  ##
  ##
  ##

  # options[:dias_permitido_receber] default = 0
  # options[:data_vencimento]

  def gera_boleto_vencido options = {}

#    dias_para_pagar_apos_emissao = options[:dias_para_pagar_apos_emissao].nil? ? 15 : options[:dias_para_pagar_apos_emissao]

    boleto = Boleto.new()
    boleto.promissoria_id = self.id
    boleto.status = 38 # Boleto não pago
    boleto.data_emissao = Time.now.to_date
    boleto.valor_original = self.valor_original
    data_vencimento = options[:data_vencimento].nil? ? (Time.now + 7.day).to_date : options[:data_vencimento]
    boleto.data_vencimento = data_vencimento
    data_base = data_vencimento
    boleto.dias_permitido_receber = options[:dias_permitido_receber].nil? ? 0 : options[:dias_permitido_receber]

    boleto.cod_sac = venda.get_cod_sacado
    boleto.seu_numero = self.gera_seu_numero
    boleto.gera_nosso_numero

    v = self.get_valores data_base
    dias_atraso = v[:dias_atraso]
    boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_mora], 2)
    boleto.perc_poup = v[:valor_mora] / v[:valor_original]
    boleto.atualizacao = v[:valor_mora] - v[:valor_original]

    boleto.mensagem1 = Biblioteca::converte_texto("Nao receber apos vencimento.")
    boleto.mensagem2 = Biblioteca::converte_texto(self.gera_mensagem2)
    boleto.mensagem3 = Biblioteca::converte_texto(format("Valor em %s: %s", Biblioteca::dt_mysql_to_s(self.data_vencimento.to_s), Biblioteca::to_my_moeda(v[:valor_vencimento])))
    boleto.mensagem4 = Biblioteca::converte_texto(format("%s dias de atraso: Multa= %s", dias_atraso, Biblioteca::to_my_moeda(v[:multa])))
    boleto.mensagem5 = Biblioteca::converte_texto(format("Juros= %s e Correção= %s", Biblioteca::to_my_moeda(v[:juros]), Biblioteca::to_my_moeda(v[:correcao_monetaria])))
    boleto.mensagem6 = Biblioteca::converte_texto("Hansafly: (21)2632-7222 e 9602-3878")

    # Valor em 12/12/2012: R$ 2.345,12
    # 234 dias de atraso: Multa = R$ 200,00
    # Juros = R$ 90,00 e Correção = R$ 900,00
    # 1234567890123456789012345678901234567890

    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    boleto.valor_juros = 0
    boleto.valor_multa = 0

    boleto.save
    boleto.gera_sql_sicob
    return boleto

  end




def gera_boleto_vincendo3 options = {}
  # Options:
  # dias_para_pagar_apos_emissao
  # options[:dias_permitido_receber] default = 90
  # options[:data_vencimento]

  boleto = Boleto.new()
  boleto.promissoria_id = self.id
  boleto.status = 38 # Boleto não pago
  boleto.data_emissao = Time.now.to_date
  boleto.valor_original = self.valor_original
  boleto.dias_permitido_receber = options[:dias_permitido_receber].nil? ? 90 : options[:dias_permitido_receber]
  data_base = options[:data_vencimento].nil? ? Biblioteca::date2time(self.data_vencimento).to_date : options[:data_vencimento]
  boleto.data_vencimento = data_base
  boleto.cod_sac = venda.get_cod_sacado
  boleto.seu_numero = self.gera_seu_numero
  boleto.gera_nosso_numero

  v = self.get_valores data_base



end






def gera_boleto_vincendo2 options = {}
  # Options:
  # dias_para_pagar_apos_emissao
  # options[:dias_permitido_receber] default = 90
  # options[:data_vencimento]


    boleto = Boleto.new()
    boleto.promissoria_id = self.id
    boleto.status = 38 # Boleto não pago
    boleto.data_emissao = Time.now.to_date
    boleto.valor_original = self.valor_original
    data_vencimento = options[:data_vencimento].nil? ? Biblioteca::date2time(self.data_vencimento).to_date : options[:data_vencimento]
    data_base = data_vencimento
    boleto.dias_permitido_receber = options[:dias_permitido_receber].nil? ? 90 : options[:dias_permitido_receber]

    ##
    ##  Corrige dia de vencimento
    ##
    # piso = 15 ## Vendas antigas feitas pelo Miranda antes de 1/1/2008
    piso = (self.venda.cod_corretor == 10 and self.venda.get_data_venda < Date.new(2008,1,1)) ? 15 : 1
    boleto.data_vencimento = Biblioteca::corrige_piso_dia(data_vencimento, piso)

    boleto.cod_sac = venda.get_cod_sacado
    boleto.seu_numero = self.gera_seu_numero
    boleto.gera_nosso_numero

    v = self.get_valores data_base

    ##
    ## Calcula correcao e valor do boleto
    ##
    if options[:valor].nil? then
      boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_vencimento], 2)
      boleto.perc_poup = v[:valor_vencimento] / v[:valor_original]
      boleto.atualizacao = v[:valor_vencimento] - v[:valor_original]
    else
      valor = (options[:valor]).to_f
      boleto.valor_titulo = valor
      boleto.perc_poup = valor / v[:valor_original]
      boleto.atualizacao = valor - v[:valor_original]
    end

   #boleto.mensagem0 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto(self.gera_mensagem1)
    boleto.mensagem2 = Biblioteca::converte_texto(self.gera_mensagem2)
    boleto.mensagem3 = Biblioteca::converte_texto("Pagar: Lotericas, CEF ou rede bancaria")
    boleto.mensagem4 = Biblioteca::converte_texto("preferencialmente Lotericas ou CEF")
    boleto.mensagem5 = Biblioteca::converte_texto("Hansa Fly  tel:(21)2632-7222,99602-3878")
    boleto.mensagem6 = Biblioteca::converte_texto("e-mail: adm@hansafly.com")


    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    valor = boleto.valor_titulo
    boleto.valor_juros = Biblioteca::arredonda_float(valor * self.venda.juros / 100.0 / 30.0, 2)
    boleto.valor_multa = Biblioteca::arredonda_float(valor * self.venda.multa / 100.0, 2)

    boleto.save
    boleto.gera_sql_sicob
    return boleto

  end






  def gera_boleto_vincendo

    boleto = Boleto.new()
    boleto.promissoria_id = self.id
    boleto.status = 38 # Boleto não pago
    boleto.data_emissao = Time.now.to_date
    boleto.valor_original = self.valor_original
    data_vencimento = Biblioteca::date2time(self.data_vencimento).to_date
    data_base = data_vencimento
    boleto.dias_permitido_receber = 30

    ##
    ##  Corrige dia de vencimento
    ##
    # piso = 15 ## Vendas antigas feitas pelo Miranda
    piso = (self.venda.cod_corretor == 10) ? 15 : 1
    boleto.data_vencimento = Biblioteca::corrige_piso_dia(data_vencimento, piso)

    boleto.cod_sac = venda.get_cod_sacado
    boleto.seu_numero = self.gera_seu_numero
    boleto.gera_nosso_numero

    v = self.get_valores data_base

    ##
    ## Calcula correcao e valor do boleto
    ##
#    dias_atraso = v[:dias_atraso]
    boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_vencimento], 2)
    boleto.perc_poup = v[:valor_vencimento] / v[:valor_original]
    boleto.atualizacao = v[:valor_vencimento] - v[:valor_original]

   #boleto.mensagem0 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto("Apos vencto pagar na CEF ou Lotericas")
    boleto.mensagem2 = Biblioteca::converte_texto(self.gera_mensagem2)
    boleto.mensagem3 = Biblioteca::converte_texto("Pagar: Lotericas, CEF ou rede bancaria")
    boleto.mensagem4 = Biblioteca::converte_texto("preferencialmente Lotericas ou CEF")
    boleto.mensagem5 = Biblioteca::converte_texto("Hansa Fly - tel (21)2632-7222, 9602-3878")
    boleto.mensagem6 = Biblioteca::converte_texto("e-mail: adm@hansafly.com")

    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    valor = boleto.valor_titulo
    boleto.valor_juros = Biblioteca::arredonda_float(valor * self.venda.juros / 100.0 / 30.0, 2)
    boleto.valor_multa = Biblioteca::arredonda_float(valor * self.venda.multa / 100.0, 2)

    boleto.save
    boleto.gera_sql_sicob
    return boleto

  end


  ##
  ## IMPORTANTE:  Trocar gera_boleto_vincendo POR gera_boleto_vincendo2
  ##
  ##

  def gera_boleto_automatico
    boleto = nil
    # paga, atrasada, mora, vincenda
    situacao = self.get_situacao

    options = {}

    if [:vincenda, :mora].include?(situacao) then
      boleto = gera_boleto_vincendo2 options
    end

    if situacao == :atrasada then
      boleto = gera_boleto_vencido options
    end

    return boleto
end


##
## Versão 2 - atual
##
def gera_boletob tipo_boleto, data_vencimento, data_base
  ##  Integer, Time, Time

  # 46 - Normal
  # 47 - Atrasada
  # 48 - Prorrogado - Dilação
  # 49 - Antigo
  # 50 - Sem Boleto
  if ![46, 47, 48, 49, 50].include?(tipo_boleto) then
    puts ">>> ERRO: tipo de boleto inválido!"
    return
  end

  puts "+++++++++++++++"
  puts format("Tipo = %s", tipo_boleto)
  puts "+++++++++++++++"

  boleto = Boleto.new()
  boleto.promissoria_id = self.id
  boleto.status = 38 # Boleto não pago
  boleto.data_emissao = Time.now.to_date
  boleto.valor_original = self.valor_original
  data_vencimento = (data_vencimento.to_s.empty? ? (Biblioteca::date2time(self.data_vencimento)).to_date : data_vencimento.to_date)
  data_base = (data_base.to_s.empty? ? data_vencimento : data_base)
  dias_permitido_receber = 90

  ##
  ##  Corrige dia de vencimento
  ##
  if self.venda.cod_corretor == 10 then
    piso = 15 ## Vendas antigas feitas pelo Miranda
  else
    piso = 1
  end
  boleto.data_vencimento = Biblioteca::corrige_piso_dia(data_vencimento, piso)

  ##
  ## Busca cpf do comprador.
  ##   verificar caso quando sao mais de 1 comprador!
  ##
  @cpf = 0
  #puts "venda = #{venda.id}"
  self.venda.compradors.each do |comprador|
    #puts "comprador = #{comprador.id}"
    @cpf = comprador.pessoa.cpf
  end
  #puts "cpf = #{@cpf}"
  if @cpf.nil? then
    puts ">>>> CPF NULL"
  end

  ##
  ## Baseado no CPF, busca codigo do sacado
  ##
  ##
  ## (Para Fazer): atualização automatica do *.mdb
  ##
  boleto.cod_sac = Minha.new.cpf_to_codsac(@cpf)

  via = self.boletos.size + 1
  area_nome = self.venda.lote.area.nome
  lote_numero = self.venda.lote.numero

  if area_nome == "A" and lote_numero == "1" then
    lote_numero = "123"
  end

  ##
  ## Calcula seu_numero
  ##
#  seu_numero = format("%s-%s-%s/%s", area_nome, lote_numero, self.num, self.num_total)
#  seu_numero = self.venda.lote.quadra.nil? ? format("%s-%s-%s/%s", area_nome, lote_numero, self.num, self.num_total) : format("%s-%s-%s-%s/%s", area_nome, self.venda.lote.quadra, lote_numero, self.num, self.num_total)
  seu_numero = format("%s-%s/%s", self.venda.lote.to_label, self.num, self.num_total)
  seu_numero = via > 1 ? format("%s.%s", seu_numero, via) : seu_numero
  boleto.seu_numero = seu_numero

  puts "promissória = #{self.id}"
  puts "data_base = #{data_base}"


  puts ">>>> ANTES GET_VALORES"
  v = self.get_valores data_base
  puts ">>>> DEPOIS GET_VALORES"

  ## 46 - Normal
  ## 47 - Atrasado
  ## 48 - Prorrogado
  ## 49 - Antigo
  ## 50 - Não bancário - sem impressão


  if tipo_boleto == 46 then
    ##
    ## Normal sem Juros
    ##

    dias_permitido_receber = 90

    ##
    ## Calcula correcao e valor do boleto
    ##
    dias_atraso = v[:dias_atraso]
    boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_vencimento], 2)
    boleto.perc_poup = v[:valor_vencimento] / v[:valor_original]
    boleto.atualizacao = v[:valor_vencimento] - v[:valor_original]

    boleto.mensagem1 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto("Apos vencto pagar na CEF ou Lotericas")
    boleto.mensagem3 = Biblioteca::converte_texto("Pagar: Lotericas, CEF ou rede bancaria")
    boleto.mensagem4 = Biblioteca::converte_texto("preferencialmente Lotericas ou CEF")
    boleto.mensagem5 = Biblioteca::converte_texto("Hansa Fly  tel:(21)2632-7222,99602-3878")
    boleto.mensagem6 = Biblioteca::converte_texto("e-mail: adm@hansafly.com")

    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    valor = boleto.valor_titulo
    boleto.valor_juros = Biblioteca::arredonda_float(valor * self.venda.juros / 100.0 / 30.0, 2)
    boleto.valor_multa = Biblioteca::arredonda_float(valor * self.venda.multa / 100.0, 2)

    ##
    ## Identificação da parcela
    ##
    if cod_tipo_parcela == 29 then
      # Mensal
      tipo_parcela = 'mensal'
    end
    if cod_tipo_parcela == 28 then
      # Intermediaria
      tipo_parcela = 'interm.'
    end
    if cod_tipo_parcela == 27 then
      # Entrada
      tipo_parcela = 'entrada'
    end
    msg_via = via > 1 ? format(" %ia via", via.to_i) : ""
    boleto.mensagem1 = format("### Lote %s ###", self.venda.lote.to_label)
    boleto.mensagem2 = format("Ref: NP (%s) %s de %s %s", tipo_parcela, self.num, self.num_total, msg_via).strip





    boleto.gera_nosso_numero
  end

  if tipo_boleto == 47 then
    ##
    ## Atrasado - boleto especial
    ##

    dias_permitido_receber = 0

    ##
    ## Calcula correcao e valor do boleto
    ##
    #      dias_atraso = self.dias_em_atraso_data_base data_base
    #      data_primeira_periodo = self.get_data_reajuste_promissoria_mensal
    #      self.set_correcao boleto, data_primeira_periodo

    dias_atraso = v[:dias_atraso]
    boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_mora], 2)
    boleto.perc_poup = v[:valor_mora] / v[:valor_original]
    boleto.atualizacao = v[:valor_mora] - v[:valor_original]

    #      valor_vencimento = boleto.valor_titulo
    #      multa = Biblioteca::arredonda_float(valor_vencimento * self.venda.multa / 100.0, 2)
    #      juros = Biblioteca::arredonda_float(valor_vencimento * self.venda.juros / 100.0 / 30.0 , 2)
    #
    #      boleto.valor_titulo = valor_vencimento.to_f + multa.to_f + (dias_atraso.to_f * juros.to_f)

    boleto.mensagem1 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto("Nao receber apos vencimento.")
    boleto.mensagem3 = Biblioteca::converte_texto(format("Valor em %s: %s", Biblioteca::dt_mysql_to_s(self.data_vencimento.to_s), Biblioteca::to_my_moeda(v[:valor_vencimento])))
    boleto.mensagem4 = Biblioteca::converte_texto(format("%s dias de atraso. Multa = %s", dias_atraso, Biblioteca::to_my_moeda(v[:multa])))
    boleto.mensagem5 = Biblioteca::converte_texto(format("e Juros = %s", Biblioteca::to_my_moeda(v[:juros])))
    boleto.mensagem6 = Biblioteca::converte_texto("Hansafly: (21)2632-7222 e 9602-3878")

    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    boleto.valor_juros = 0
    boleto.valor_multa = 0

    ##
    ## Identificação da parcela
    ##
    if cod_tipo_parcela == 29 then
      tipo_parcela = 'mensal'
    end
    if cod_tipo_parcela == 28 then
      tipo_parcela = 'interm.'
    end
    if cod_tipo_parcela == 27 then
      tipo_parcela = 'entrada'
    end
    men_1 = format("Lote %s-%s", area_nome, lote_numero)
    men_2 = format("NP (%s) %s de %s", tipo_parcela, self.num, self.num_total)
    if via > 1 then
      men_2 = men_2 + format(" v=%i", via.to_i)
    end
    boleto.mensagem2 = men_1 + " ref: " + men_2

    boleto.gera_nosso_numero
  end

  if tipo_boleto == 48 then
    ##
    ## Normal com Juros
    ##

    dias_permitido_receber = 30

    ##
    ## Calcula correcao e valor do boleto
    ##
    dias_atraso = v[:dias_atraso]

    boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_mora], 2)
    boleto.perc_poup = v[:valor_mora] / v[:valor_original]
    boleto.atualizacao = v[:valor_mora] - v[:valor_original]

    boleto.mensagem1 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto("Apos vencto pagar na CEF ou Lotericas")
    boleto.mensagem3 = Biblioteca::converte_texto("Pagar: Lotericas, CEF ou rede bancaria")
    boleto.mensagem4 = Biblioteca::converte_texto("preferencialmente Lotericas ou CEF")
    boleto.mensagem5 = Biblioteca::converte_texto("Hansa Fly - tel (21)2632-7222, 9602-3878")
    boleto.mensagem6 = Biblioteca::converte_texto("e-mail: adm@hansafly.com")

    ##
    ## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
    ##
    valor = boleto.valor_titulo
    boleto.valor_juros = Biblioteca::arredonda_float(boleto.valor_titulo.to_f * self.venda.juros / 100.0 / 30.0, 2)
    boleto.valor_multa = Biblioteca::arredonda_float(boleto.valor_titulo.to_f * self.venda.multa / 100.0, 2)

    ##
    ## Identificação da parcela
    ##
    if cod_tipo_parcela == 29 then
      tipo_parcela = 'mensal'
    end
    if cod_tipo_parcela == 28 then
      tipo_parcela = 'interm.'
    end
    if cod_tipo_parcela == 27 then
      tipo_parcela = 'entrada'
    end
    men_1 = format("Lote %s-%s", area_nome, lote_numero)
    men_2 = format("NP (%s) %s de %s", tipo_parcela, self.num, self.num_total)
    if via > 1 then
      men_2 = men_2 + format(" v=%i", via.to_i)
    end
    boleto.mensagem2 = men_1 + " ref: " + men_2

    boleto.gera_nosso_numero
  end


  if tipo_boleto == 50 then
    ##
    ## Boleto nao bancario - sem impressao
    ##

    dias_permitido_receber = 30

    ##
    ## Calcula correcao e valor do boleto
    ##
    #dias_atraso = ((Biblioteca::dt_mysql_to_time(boleto.data_emissao.to_s) - Biblioteca::dt_mysql_to_time(self.data_vencimento.to_s)) / 86400).to_i
    dias_atraso = self.dias_em_atraso_data_base data_base
    data_primeira_periodo = self.get_data_reajuste_promissoria_mensal
    self.set_correcao boleto, data_primeira_periodo

    valor_vencimento = boleto.valor_titulo.to_f
    multa = Biblioteca::arredonda_float(valor_vencimento * self.venda.multa / 100.0, 2)
    juros = Biblioteca::arredonda_float(valor_vencimento * self.venda.juros / 100.0 / 30.0, 2)
    boleto.valor_titulo = valor_vencimento.to_f + multa.to_f + (dias_atraso.to_f * juros.to_f)

    boleto.mensagem1 = Biblioteca::converte_texto("1234567890123456789012345678901234567890")
    boleto.mensagem1 = Biblioteca::converte_texto("")
    boleto.mensagem3 = Biblioteca::converte_texto("Pagar somente na Hansa Fly")
    boleto.mensagem4 = Biblioteca::converte_texto("")
    boleto.mensagem5 = Biblioteca::converte_texto("Hansa Fly - tel (21)2643-3970, 9602-3878")
    boleto.mensagem6 = Biblioteca::converte_texto("e-mail: adm@hansafly.com")

    valor = boleto.valor_titulo.to_f
    multa = Biblioteca::arredonda_float(valor * self.venda.multa / 100.0, 2)
    juros = Biblioteca::arredonda_float(valor * self.venda.juros / 100.0 / 30.0, 2)

    boleto.valor_juros = juros
    boleto.valor_multa = multa

    ##
    ## Identificação da parcela
    ##
    if cod_tipo_parcela == 29 then
      tipo_parcela = 'mensal'
    end
    if cod_tipo_parcela == 28 then
      tipo_parcela = 'interm.'
    end
    if cod_tipo_parcela == 27 then
      tipo_parcela = 'entrada'
    end
    men_1 = format("Lote %s-%s", area_nome, lote_numero)
    men_2 = format("NP (%s) %s de %s", tipo_parcela, self.num, self.num_total)
    if via > 1 then
      men_2 = men_2 + format(" v=%i", via.to_i)
    end
    boleto.mensagem2 = men_1 + " ref: " + men_2

    boleto.nosso_numero = ""
  end


  ##
  ## Grave Boleto e Título em arquivo SQL para COBCAIXA
  ##

  puts "%%%%%%%%%%%%%%%%%%%"
  puts ">>>>>>>>>>>>> Data Vencimento = #{boleto.data_vencimento}"
  puts ">>>>>>>>>>>>> Data Emissão = #{boleto.data_emissao}"
  puts "%%%%%%%%%%%%%%%%%%%"

  boleto.save
  if tipo_boleto != 50 then # 50 - Boleto nao bancario - sem boleto
    boleto.gera_titulob(dias_permitido_receber)
  end
  return boleto
end





##
## NOVA Versão
##

def gera_boleto options = {}
  # Options:
  # dias_para_pagar_apos_emissao
  # options[:tipo_boleto]
  # options[:dias_permitido_receber] default = 90
  # options[:data_vencimento]

  #puts "options[:tipo_boleto] = #{options[:tipo_boleto]}"
  #puts "situacao = #{self.get_situacao}"
  if options[:tipo_boleto].nil? then
    case self.get_situacao
      when :vincenda, :mora
        #puts "1"
        options[:tipo_boleto] = :vincendo
      when :atrasada
        #puts "2"
        options[:tipo_boleto] = :vencido
      else
        #puts "3"
        options[:tipo_boleto] = :vencido
    end
  end
  #puts "tipo_boleto = #{options[:tipo_boleto]}"

#  boleto = gera_boleto_vincendo2 options
#  boleto = gera_boleto_vencido options


  boleto = Boleto.new()
  boleto.promissoria_id = self.id
  boleto.status = 38 # Boleto não pago
  boleto.data_emissao = Time.now.to_date
  boleto.valor_original = self.valor_original

  if !options[:data_vencimento].nil? then
    data_base = options[:data_vencimento]
  else
    data_base = Biblioteca::date2time(self.data_vencimento).to_date if options[:tipo_boleto] == :vincendo
    if options[:tipo_boleto] == :vencido then
      options[:tipo_boleto] = :vincendo if (Time.now.to_date - (Biblioteca::date2time(self.data_vencimento).to_date)) <= 30
      data_base = Time.now.to_date + 5
    end
  end
  #puts "data_base = #{data_base}"
  v = self.get_valores data_base

  default_dias_permitido_receber = (options[:tipo_boleto]  == :vincendo ? 90 : 0)
  boleto.dias_permitido_receber = (options[:dias_permitido_receber].nil? ? default_dias_permitido_receber : options[:dias_permitido_receber])

  boleto.data_vencimento = data_base

  boleto.cod_sac = venda.get_cod_sacado
  boleto.seu_numero = self.gera_seu_numero
  boleto.gera_nosso_numero


##
## Calcula correcao e valor do boleto
##
  if !options[:valor].nil? then
    valor = (options[:valor]).to_f
    boleto.valor_titulo = valor
    boleto.perc_poup = valor / v[:valor_original]
    boleto.atualizacao = valor - v[:valor_original]
  else
    if options[:tipo_boleto] == :vincendo then
      boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_vencimento], 2)
      boleto.perc_poup = v[:valor_vencimento] / v[:valor_original]
      boleto.atualizacao = v[:valor_vencimento] - v[:valor_original]
    else
      dias_atraso = v[:dias_atraso]
      boleto.valor_titulo = Biblioteca::arredonda_float(v[:valor_mora], 2)
      boleto.perc_poup = v[:valor_mora] / v[:valor_original]
      boleto.atualizacao = v[:valor_mora] - v[:valor_original]
    end
  end

#                    "1234567890123456789012345678901234567890"
  boleto.mensagem1 = "Apos vencimento SOMENTE CEF ou Lotericas"[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vincendo
  boleto.mensagem1 = "##### Nao receber apos vencimento  #####"[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vencido

  boleto.mensagem2 = "### Lote #{self.venda.lote.to_label} ###"[0..39].strip.ljust(40, ' ')

  boleto.mensagem3 = "HANSA FLY Empreendimentos Imob. Ltda."[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vincendo
  boleto.mensagem3 = "Pagamento com #{dias_atraso} dias de atraso."[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vencido
  boleto.mensagem4 = "WhatsApp:(21)99602-3878 adm@hansafly.com"[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vincendo
  boleto.mensagem4 = "Multa= #{Biblioteca::to_my_moeda(v[:multa])}; Encargos= #{Biblioteca::to_my_moeda(v[:juros]+v[:correcao_monetaria])}"[0..39].ljust(40, ' ') if options[:tipo_boleto] == :vencido

  boleto.mensagem5 = "-------  NAO RECEBER EM CHEQUE  -------"[0..39].ljust(40, ' ')

  msg_via = (get_via > 1 ? " - #{get_via}a via" : "")
  case cod_tipo_parcela
    when 29
      tipo_parcela = "#{self.venda.lote.to_label}: NP(mensal) #{self.num} de #{self.num_total}#{msg_via}"
    when 28
      tipo_parcela = "#{self.venda.lote.to_label}: NP(interm.) #{self.num} de #{self.num_total}#{msg_via}"
    when 27
      tipo_parcela = "#{self.venda.lote.to_label}: NP(entrada) #{self.num} de #{self.num_total}#{msg_via}"
    when 67
      tipo_parcela = "## #{self.venda.lote.to_label}: PARCELA ESPECIAL DE QUITAÇÃO ##"
    when 75
      mes = "#{Biblioteca.mes2nome self.data_vencimento.beginning_of_month.prev_month.month}/#{self.data_vencimento.beginning_of_month.prev_month.year}"
      tipo_parcela = "## Casa(#{self.venda.lote.to_label}): Aluguel #{mes} ##"
    when 77
      tipo_parcela = "#{self.venda.lote.to_label}: 75% de NP(mensal) - ESP ##{self.num} #{msg_via}"

  end
  boleto.mensagem6 = "#{tipo_parcela}"[0..39].ljust(40, ' ')






##
## Calcula juros/multa a cobrar no boleto em caso de pagamento apos o vencimento
##
  valor = boleto.valor_titulo
  boleto.valor_juros = Biblioteca::arredonda_float(valor * self.venda.juros / 100.0 / 30.0, 2)
  boleto.valor_multa = Biblioteca::arredonda_float(valor * self.venda.multa / 100.0, 2)

  boleto.save
  boleto.gera_sql_sicob
  return boleto







  return boleto
end



def Promissoria.get_promissoria slote, sparcela
  s = slote.split("-")
  area = s[0]
  lote = s[1]
  s = sparcela.split("/")
  num = s[0]
  num_total = s[1]
  lote = Lote::get_lote(slote)
  promissorias = self.find(:all,
                           :conditions => format("num = %s and num_total = %s and venda_id = %s", num, num_total, lote.get_venda.id))

  if promissorias.size > 1 then
    puts ">>> ERRO: existe mais de uma promissória <<<<<"
  end
  return promissorias[0]
end


def teste
  puts 'Teste!!'
  self.lista_vincendos 2010, 2
end


end






