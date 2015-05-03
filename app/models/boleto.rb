# coding: utf-8

class Boleto < ActiveRecord::Base
  has_one :pagamento
  belongs_to :promissoria


  def Boleto.get_boleto seu_numero
    boleto = self.find(:first, :conditions => format("seu_numero = '%s'", seu_numero))
  end



  #def num_boletos
  #  return self.boletos.size
  #end



  def dv11 n
    if n.length < 2
      return nil
    end

    soma = 0
    l = n.length
    multiplicador = 2
    (1..(l)).each  do |i|
      c = n[l-i,1];
      parcela = c.to_i * multiplicador
      soma += parcela
      multiplicador < 9 ? multiplicador += 1 : multiplicador = 2
    end

    resto = soma % 11

    if (resto >= 0 and resto <= 1)
      digito = 0
    else
      digito = 11 - resto
    end
    return n + digito.to_s
  end




  def gera_nosso_numero
    ob = Boleto.find(:last, :order => "nosso_numero")
    p = ob.nosso_numero
    novo = p.to_s.size.to_i
    idx = (p[1,p.size].to_i / 10) + 1
    sidx = "8" + "0" * (16 - idx.to_s.size - 2) + idx.to_s
    self.nosso_numero = dv11(sidx)
  end


  def efetua_pagamento \
          status_boleto, \
          status_pagamento, \
          valor_multa, \
          valor_juros, \
          valor_desconto, \
          valor_tarif_banco, \
          valor_pago, \
          data_pagamento, \
          comentarios

    self.status = status_boleto
    self.promissoria.cod_status = status_pagamento
    self.promissoria.save
    self.save

    pagamento = Pagamento.new
    pagamento.efetua_pagamento self,\
              status_boleto, \
              status_pagamento, \
              valor_multa, \
              valor_juros, \
              valor_desconto, \
              valor_tarif_banco, \
              valor_pago, \
              data_pagamento, \
              comentarios

  end


  def to_s
    return "[#{seu_numero}, dt_original:#{promissoria.data_vencimento}, vencimento:#{data_vencimento}, \
            valor_original:#{valor_original.to_currency}, valor_titulo:#{valor_titulo.to_currency}, idx:#{Biblioteca::arredonda_float(((perc_poup-1)*100), 4)}%]"

  end



  def print
    printf "------------------------------\n"
    printf "-------  BOLETO --------------\n"
    printf "------------------------------\n"
    printf "promissoria_id = %s\n", self.promissoria_id
    printf "status = %s\n", self.status
    printf "nosso_numero = %s\n", self.nosso_numero
    printf "cod_sac = %s\n", self.cod_sac
    printf "seu_numero = %s\n", self.seu_numero
    printf "dt_vecto = %s\n", self.data_vencimento
    printf "dt_emissao = %s\n", self.data_emissao
    printf "valor_original = %s\n", self.valor_original
    printf "atualizacao = %s\n", self.atualizacao
    printf "perc_poup = %s\n", self.perc_poup
    printf "valor_titulo = %s\n", self.valor_titulo
    printf "valor_multa = %s\n", self.valor_multa
    printf "valor_juros = %s\n", self.valor_juros
    printf "mensagem1 = %s\n", self.mensagem1
    printf "mensagem2 = %s\n", self.mensagem2
    printf "mensagem3 = %s\n", self.mensagem3
    printf "mensagem4 = %s\n", self.mensagem4
    printf "mensagem5 = %s\n", self.mensagem5
    printf "mensagem6 = %s\n\n", self.mensagem6
    #printf "-------------------------------------\n\n"
  end




  def gera_sql_sicob
    cod_sac = ""
    nosso_numero = ""
    dt_vecto = ""
    dt_emissao = ""
    valor_titulo = ""
    valor_juros = ""
    valor_multa = ""
    mensagem1 = ""
    mensagem2 = ""
    mensagem3 = ""
    mensagem4 = ""
    mensagem5 = ""
    mensagem6 = ""

    cod_sac = self.cod_sac.to_s
    cod_sac = cod_sac.size == 1 ? "0" + cod_sac : cod_sac
    cod_sac = " " * (15 - cod_sac.size) + cod_sac
    nosso_numero = self.nosso_numero
    dt_vecto = Biblioteca::date2sicob(self.data_vencimento)
    dt_emissao = Biblioteca::date2sicob(self.data_emissao)
    valor_titulo = self.valor_titulo.to_s.sub(/[.]/,",")
    mensagem1 = self.mensagem1
    mensagem2 = self.mensagem2
    mensagem3 = self.mensagem3
    mensagem4 = self.mensagem4
    mensagem5 = self.mensagem5
    mensagem6 = self.mensagem6
    valor_juros = self.valor_juros.to_s.sub(/[.]/,",")
    valor_multa = self.valor_multa.to_s.sub(/[.]/,",")

    dt_desconto = dt_vecto
    valor_desconto = "0,00"
    valor_abatimento = "0,00"
    #dt_multa = dt_vecto
    dt_multa = Biblioteca::time2sicob(Biblioteca::date2time(self.data_vencimento).advance(:days => self.promissoria.venda.dias_carencia))
    #dt_multa = Biblioteca::dt_access_to_dt_mysql((self.data_vencimento + self.promissoria.venda.dias_carencia).to_s)

    cod_cedente = 1
    cod_carteira = 14
    aceite = "1"
    cod_especie = "99"
    inst_cobranca = 0         # boolean
    prazo_prot_dev = self.dias_permitido_receber
    opc_vecto = "1"
    cod_moeda = "09"
    uso_cedente = " "
    remessa = 0               # boolean
    retorno = 0               # boolean
    impresso = 0              # boolean
    movimentacao = 0          # boolean
    tipo_bloq = 1             # boolean
    compensavel = 0           # boolean
    cod_ocor_remessa = "01"
    cod_ocor_retorno = "null"
    parcela = "null"
    total_parcelas = "null"
    cod_barras = "null"
    num_remessa = "null"
    campo1 = "null"
    campo2 = "null"
    campo3 = "null"
    campo4 = "null"
    campo5 = "null"
    codrej1 = "null"
    codrej2 = "null"
    codrej3 = "null"

    tip_dt_ocorrencia = "null"
    dt_pgto = "null"
    vr_pago = "0,00"
    vr_des_ef = "0,00"
    vr_acr_ef = "0,00"
    vr_aba_ef = "0,00"

    mov_manual = 0          # boolean
    avalista = "null"
    cpf_cgc_aval = "null"

    tipo_pessoa_aval = 1    # boolean
    num_rem = 0
    lock = 0                # boolean
    confirma = 0            # boolean

    carne = 0
    vr_jur_ef = "0,00"
    vr_mul_ef  = "0,00"
    vr_cred_ef  = "0,00"
    vr_tarifa = "0,00"

    dt_cred_ef = "null"
    dt_tari_ef = "null"
    canal_pgto = "null"
    forma_pgto = "null"
    float_pgto = "null"


    s = "INSERT INTO tbTitulos "
    s += "("
    s += "CodCedente,"
    s += "CodSac,"
    s += "SeuNum,"
    s += "CodCarteira,"
    s += "Aceite,"
    s += "CodEspecie,"
    s += "InstCobranca,"
    s += "PrazoProtDev,"
    s += "OpcVecto,"
    s += "DtVecto,"
    s += "DtEmissao,"
    s += "CodMoeda,"
    s += "ValorTitulo,"
    s += "ValorJuros,"
    s += "DtDesconto,"
    s += "ValorDesconto,"
    s += "ValorAbatimento,"
    s += "DtMulta,"
    s += "ValorMulta,"
    s += "UsoCedente,"
    s += "NossoNumero,"
    s += "Remessa,"
    s += "Retorno,"
    s += "impresso,"
    s += "Movimentacao,"
    s += "TipoBloq,"
    s += "Compensavel,"
    s += "CodOcorRemessa,"
    s += "CodOcorRetorno,"
    s += "Parcela,"
    s += "TotalParcelas,"
    s += "CodBarras,"
    s += "NumRemessa,"
    s += "Mensagem1,"
    s += "Mensagem2,"
    s += "Mensagem3,"
    s += "Mensagem4,"
    s += "Mensagem5,"
    s += "Mensagem6,"
    s += "Campo1,"
    s += "Campo2,"
    s += "Campo3,"
    s += "Campo4,"
    s += "Campo5,"
    s += "CODREJ1,"
    s += "CODREJ2,"
    s += "CODREJ3,"
    s += "TipDtOcorrencia,"
    s += "DtPgto,"
    s += "VrPago,"
    s += "VrDesEf,"
    s += "VrAcrEf,"
    s += "VrAbaEf,"
    s += "MovManual,"
    s += "Avalista,"
    s += "CPfCGCAval,"
    s += "TipoPessoaAval,"
    s += "NumRem,"
    s += "Lock,"
    s += "CONFIRMA,"
    s += "CARNE,"
    s += "VRJUREF,"
    s += "VRMULEF,"
    s += "VRCREDEF,"
    s += "VRTARIFA,"
    s += "DtCredef,"
    s += "DtTarief,"
    s += "CanalPgto,"
    s += "FormaPgto,"
    s += "FloatPgto"
    s += ")"
    s += " VALUES "
    s += " ("
    s += cod_cedente.to_s
    s += ', "' + cod_sac + '"'
    s += ', "' + self.seu_numero + '"'
    s += ", " + cod_carteira.to_s
    s += ', "' + aceite + '"'
    s += ', "' + cod_especie + '"'
    s += ', ' + inst_cobranca.to_s
    s += ', ' + prazo_prot_dev.to_s
    s += ', "' + opc_vecto + '"'
    s += ', ' + dt_vecto
    s += ', ' + dt_emissao
    s += ', "' + cod_moeda + '"'
    s += ', "' + valor_titulo + '"'
    s += ', "' + valor_juros + '"'
    s += ', ' + dt_desconto
    s += ', "' + valor_desconto + '"'
    s += ', "' + valor_abatimento + '"'
    s += ', ' + dt_multa
    s += ', "' + valor_multa + '"'
    s += ', "' + uso_cedente + '"'
    s += ', "' + nosso_numero.to_s + '"'
    s += ', ' + remessa.to_s
    s += ', ' + retorno.to_s
    s += ', ' + impresso.to_s
    s += ', ' + movimentacao.to_s
    s += ', ' + tipo_bloq.to_s
    s += ', ' + compensavel.to_s
    s += ', "' + cod_ocor_remessa + '"'
    s += ', ' + cod_ocor_retorno
    s += ', ' + parcela
    s += ', ' + total_parcelas
    s += ', ' + cod_barras
    s += ', ' + num_remessa
    s += ', "' + mensagem1 + '"'
    s += ', "' + mensagem2 + '"'
    s += ', "' + mensagem3 + '"'
    s += ', "' + mensagem4 + '"'
    s += ', "' + mensagem5 + '"'
    s += ', "' + mensagem6 + '"'
    s += ', ' + campo1
    s += ', ' + campo2
    s += ', ' + campo3
    s += ', ' + campo4
    s += ', ' + campo5
    s += ', ' + codrej1
    s += ', ' + codrej2
    s += ', ' + codrej3
    s += ', ' + tip_dt_ocorrencia
    s += ', ' + dt_pgto
    s += ', "' + vr_pago + '"'
    s += ', "' + vr_des_ef + '"'
    s += ', "' + vr_acr_ef + '"'
    s += ', "' + vr_aba_ef + '"'
    s += ', ' + mov_manual.to_s
    s += ', ' + avalista
    s += ', ' + cpf_cgc_aval
    s += ', ' + tipo_pessoa_aval.to_s
    s += ', ' + num_rem.to_s
    s += ', ' + lock.to_s
    s += ', ' + confirma.to_s

    s += ', ' + carne.to_s
    s += ', "' + vr_jur_ef + '"'
    s += ', "' + vr_mul_ef + '"'
    s += ', "' + vr_cred_ef + '"'
    s += ', "' + vr_tarifa + '"'

    s += ', ' + dt_cred_ef
    s += ', ' + dt_tari_ef
    s += ', ' + canal_pgto
    s += ', ' + forma_pgto
    s += ', ' + float_pgto
    s += ");\n"

    sarq = self.seu_numero.to_s.sub(/[\/]/,"-")
    sarq = sarq.to_s.sub(/[.]/,"_")
    path = "/home/ricardo/hansafly/Caixa/ruby/sicob/novos"
    path = "C:\\Caixa\\ruby\\sicob\\novos\\"
    arq = Time.now.strftime("%Y-%m-%d_%H-%M-%S") + "__" + sarq + ".sql"
    f = File.new(path + arq, "w")
    f.puts s
    f.close

    return s
  end




  def gera_titulob dias_permitido_receber
    cod_sac = ""
    nosso_numero = ""
    dt_vecto = ""
    dt_emissao = ""
    valor_titulo = ""
    valor_juros = ""
    valor_multa = ""
    mensagem1 = ""
    mensagem2 = ""
    mensagem3 = ""
    mensagem4 = ""
    mensagem5 = ""
    mensagem6 = ""

    cod_sac = self.cod_sac.to_s
    cod_sac = cod_sac.size == 1 ? "0" + cod_sac : cod_sac
    cod_sac = " " * (15 - cod_sac.size) + cod_sac
    nosso_numero = self.nosso_numero
    dt_vecto = Biblioteca::date2sicob(self.data_vencimento)
    dt_emissao = Biblioteca::date2sicob(self.data_emissao)
    valor_titulo = self.valor_titulo.to_s.sub(/[.]/,",")
    mensagem1 = self.mensagem1
    mensagem2 = self.mensagem2
    mensagem3 = self.mensagem3
    mensagem4 = self.mensagem4
    mensagem5 = self.mensagem5
    mensagem6 = self.mensagem6
    valor_juros = self.valor_juros.to_s.sub(/[.]/,",")
    valor_multa = self.valor_multa.to_s.sub(/[.]/,",")

    dt_desconto = dt_vecto
    valor_desconto = "0,00"
    valor_abatimento = "0,00"
    #dt_multa = dt_vecto
    dt_multa = Biblioteca::time2sicob(Biblioteca::date2time(self.data_vencimento).advance(:days => self.promissoria.venda.dias_carencia))
    #dt_multa = Biblioteca::dt_access_to_dt_mysql((self.data_vencimento + self.promissoria.venda.dias_carencia).to_s)

    cod_cedente = 1
    cod_carteira = 14
    aceite = "1"
    cod_especie = "99"
    inst_cobranca = 0         # boolean
    prazo_prot_dev = dias_permitido_receber
    opc_vecto = "1"
    cod_moeda = "09"
    uso_cedente = " "
    remessa = 0               # boolean
    retorno = 0               # boolean
    impresso = 0              # boolean
    movimentacao = 0          # boolean
    tipo_bloq = 1             # boolean
    compensavel = 0           # boolean
    cod_ocor_remessa = "01"
    cod_ocor_retorno = "null"
    parcela = "null"
    total_parcelas = "null"
    cod_barras = "null"
    num_remessa = "null"
    campo1 = "null"
    campo2 = "null"
    campo3 = "null"
    campo4 = "null"
    campo5 = "null"
    codrej1 = "null"
    codrej2 = "null"
    codrej3 = "null"

    tip_dt_ocorrencia = "null"
    dt_pgto = "null"
    vr_pago = "0,00"
    vr_des_ef = "0,00"
    vr_acr_ef = "0,00"
    vr_aba_ef = "0,00"

    mov_manual = 0          # boolean
    avalista = "null"
    cpf_cgc_aval = "null"

    tipo_pessoa_aval = 1    # boolean
    num_rem = 0
    lock = 0                # boolean
    confirma = 0            # boolean

    carne = 0
    vr_jur_ef = "0,00"
    vr_mul_ef  = "0,00"
    vr_cred_ef  = "0,00"
    vr_tarifa = "0,00"

    dt_cred_ef = "null"
    dt_tari_ef = "null"
    canal_pgto = "null"
    forma_pgto = "null"
    float_pgto = "null"


    s = "INSERT INTO tbTitulos "
    s += "("
    s += "CodCedente,"
    s += "CodSac,"
    s += "SeuNum,"
    s += "CodCarteira,"
    s += "Aceite,"
    s += "CodEspecie,"
    s += "InstCobranca,"
    s += "PrazoProtDev,"
    s += "OpcVecto,"
    s += "DtVecto,"
    s += "DtEmissao,"
    s += "CodMoeda,"
    s += "ValorTitulo,"
    s += "ValorJuros,"
    s += "DtDesconto,"
    s += "ValorDesconto,"
    s += "ValorAbatimento,"
    s += "DtMulta,"
    s += "ValorMulta,"
    s += "UsoCedente,"
    s += "NossoNumero,"
    s += "Remessa,"
    s += "Retorno,"
    s += "impresso,"
    s += "Movimentacao,"
    s += "TipoBloq,"
    s += "Compensavel,"
    s += "CodOcorRemessa,"
    s += "CodOcorRetorno,"
    s += "Parcela,"
    s += "TotalParcelas,"
    s += "CodBarras,"
    s += "NumRemessa,"
    s += "Mensagem1,"
    s += "Mensagem2,"
    s += "Mensagem3,"
    s += "Mensagem4,"
    s += "Mensagem5,"
    s += "Mensagem6,"
    s += "Campo1,"
    s += "Campo2,"
    s += "Campo3,"
    s += "Campo4,"
    s += "Campo5,"
    s += "CODREJ1,"
    s += "CODREJ2,"
    s += "CODREJ3,"
    s += "TipDtOcorrencia,"
    s += "DtPgto,"
    s += "VrPago,"
    s += "VrDesEf,"
    s += "VrAcrEf,"
    s += "VrAbaEf,"
    s += "MovManual,"
    s += "Avalista,"
    s += "CPfCGCAval,"
    s += "TipoPessoaAval,"
    s += "NumRem,"
    s += "Lock,"
    s += "CONFIRMA,"
    s += "CARNE,"
    s += "VRJUREF,"
    s += "VRMULEF,"
    s += "VRCREDEF,"
    s += "VRTARIFA,"
    s += "DtCredef,"
    s += "DtTarief,"
    s += "CanalPgto,"
    s += "FormaPgto,"
    s += "FloatPgto"
    s += ")"
    s += " VALUES "
    s += " ("
    s += cod_cedente.to_s
    s += ', "' + cod_sac + '"'
    s += ', "' + self.seu_numero + '"'
    s += ", " + cod_carteira.to_s
    s += ', "' + aceite + '"'
    s += ', "' + cod_especie + '"'
    s += ', ' + inst_cobranca.to_s
    s += ', ' + prazo_prot_dev.to_s
    s += ', "' + opc_vecto + '"'
    s += ', ' + dt_vecto
    s += ', ' + dt_emissao
    s += ', "' + cod_moeda + '"'
    s += ', "' + valor_titulo + '"'
    s += ', "' + valor_juros + '"'
    s += ', ' + dt_desconto
    s += ', "' + valor_desconto + '"'
    s += ', "' + valor_abatimento + '"'
    s += ', ' + dt_multa
    s += ', "' + valor_multa + '"'
    s += ', "' + uso_cedente + '"'
    s += ', "' + nosso_numero.to_s + '"'
    s += ', ' + remessa.to_s
    s += ', ' + retorno.to_s
    s += ', ' + impresso.to_s
    s += ', ' + movimentacao.to_s
    s += ', ' + tipo_bloq.to_s
    s += ', ' + compensavel.to_s
    s += ', "' + cod_ocor_remessa + '"'
    s += ', ' + cod_ocor_retorno
    s += ', ' + parcela
    s += ', ' + total_parcelas
    s += ', ' + cod_barras
    s += ', ' + num_remessa
    s += ', "' + mensagem1 + '"'
    s += ', "' + mensagem2 + '"'
    s += ', "' + mensagem3 + '"'
    s += ', "' + mensagem4 + '"'
    s += ', "' + mensagem5 + '"'
    s += ', "' + mensagem6 + '"'
    s += ', ' + campo1
    s += ', ' + campo2
    s += ', ' + campo3
    s += ', ' + campo4
    s += ', ' + campo5
    s += ', ' + codrej1
    s += ', ' + codrej2
    s += ', ' + codrej3
    s += ', ' + tip_dt_ocorrencia
    s += ', ' + dt_pgto
    s += ', "' + vr_pago + '"'
    s += ', "' + vr_des_ef + '"'
    s += ', "' + vr_acr_ef + '"'
    s += ', "' + vr_aba_ef + '"'
    s += ', ' + mov_manual.to_s
    s += ', ' + avalista
    s += ', ' + cpf_cgc_aval
    s += ', ' + tipo_pessoa_aval.to_s
    s += ', ' + num_rem.to_s
    s += ', ' + lock.to_s
    s += ', ' + confirma.to_s

    s += ', ' + carne.to_s
    s += ', "' + vr_jur_ef + '"'
    s += ', "' + vr_mul_ef + '"'
    s += ', "' + vr_cred_ef + '"'
    s += ', "' + vr_tarifa + '"'

    s += ', ' + dt_cred_ef
    s += ', ' + dt_tari_ef
    s += ', ' + canal_pgto
    s += ', ' + forma_pgto
    s += ', ' + float_pgto
    s += ");\n"

    #printf "%s\n", s
    #@inserts.push(s)

    sarq = self.seu_numero.to_s.sub(/[\/]/,"-")
    sarq = sarq.to_s.sub(/[.]/,"_")
    path = "/home/ricardo/hansafly/Caixa/ruby/sicob/novos"
    path = "C:\\Caixa\\ruby\\sicob\\novos\\"
    arq = Time.now.strftime("%Y-%m-%d_%H-%M-%S") + "__" + sarq + ".sql"
    f = File.new(path + arq, "w")
    f.puts s
    f.close


    return s
  end


  def gera_titulo
    cod_sac = ""
    nosso_numero = ""
    dt_vecto = ""
    dt_emissao = ""
    valor_titulo = ""
    valor_juros = ""
    valor_multa = ""
    mensagem1 = ""
    mensagem2 = ""
    mensagem3 = ""
    mensagem4 = ""
    mensagem5 = ""
    mensagem6 = ""

    cod_sac = self.cod_sac.to_s
    cod_sac = cod_sac.size == 1 ? "0" + cod_sac : cod_sac
    cod_sac = " " * (15 - cod_sac.size) + cod_sac
    nosso_numero = self.nosso_numero
    dt_vecto = Biblioteca::dt_access_to_dt_mysql(self.data_vencimento.to_s)
    dt_emissao = Biblioteca::dt_access_to_dt_mysql(self.data_emissao.to_s)
    valor_titulo = self.valor_titulo.to_s.sub(/[.]/,",")
    mensagem1 = self.mensagem1
    mensagem2 = self.mensagem2
    mensagem3 = self.mensagem3
    mensagem4 = self.mensagem4
    mensagem5 = self.mensagem5
    mensagem6 = self.mensagem6
    valor_juros = self.valor_juros.to_s.sub(/[.]/,",")
    valor_multa = self.valor_multa.to_s.sub(/[.]/,",")

    dt_desconto = dt_vecto
    valor_desconto = "0,00"
    valor_abatimento = "0,00"
    #dt_multa = dt_vecto
    dt_multa = Biblioteca::dt_access_to_dt_mysql((self.data_vencimento + self.promissoria.venda.dias_carencia).to_s)

    cod_cedente = 1
    cod_carteira = 14
    aceite = "1"
    cod_especie = "99"
    inst_cobranca = 0         # boolean
    prazo_prot_dev = 90
    opc_vecto = "1"
    cod_moeda = "09"
    uso_cedente = " "
    remessa = 0               # boolean
    retorno = 0               # boolean
    impresso = 0              # boolean
    movimentacao = 0          # boolean
    tipo_bloq = 1             # boolean
    compensavel = 0           # boolean
    cod_ocor_remessa = "01"
    cod_ocor_retorno = "null"
    parcela = "null"
    total_parcelas = "null"
    cod_barras = "null"
    num_remessa = "null"
    campo1 = "null"
    campo2 = "null"
    campo3 = "null"
    campo4 = "null"
    campo5 = "null"
    codrej1 = "null"
    codrej2 = "null"
    codrej3 = "null"

    tip_dt_ocorrencia = "null"
    dt_pgto = "null"
    vr_pago = "0,00"
    vr_des_ef = "0,00"
    vr_acr_ef = "0,00"
    vr_aba_ef = "0,00"

    mov_manual = 0          # boolean
    avalista = "null"
    cpf_cgc_aval = "null"

    tipo_pessoa_aval = 1    # boolean
    num_rem = 0
    lock = 0                # boolean
    confirma = 0            # boolean

    carne = 0
    vr_jur_ef = "0,00"
    vr_mul_ef  = "0,00"
    vr_cred_ef  = "0,00"
    vr_tarifa = "0,00"

    dt_cred_ef = "null"
    dt_tari_ef = "null"
    canal_pgto = "null"
    forma_pgto = "null"
    float_pgto = "null"


    s = "INSERT INTO tbTitulos "
    s += "("
    s += "CodCedente,"
    s += "CodSac,"
    s += "SeuNum,"
    s += "CodCarteira,"
    s += "Aceite,"
    s += "CodEspecie,"
    s += "InstCobranca,"
    s += "PrazoProtDev,"
    s += "OpcVecto,"
    s += "DtVecto,"
    s += "DtEmissao,"
    s += "CodMoeda,"
    s += "ValorTitulo,"
    s += "ValorJuros,"
    s += "DtDesconto,"
    s += "ValorDesconto,"
    s += "ValorAbatimento,"
    s += "DtMulta,"
    s += "ValorMulta,"
    s += "UsoCedente,"
    s += "NossoNumero,"
    s += "Remessa,"
    s += "Retorno,"
    s += "impresso,"
    s += "Movimentacao,"
    s += "TipoBloq,"
    s += "Compensavel,"
    s += "CodOcorRemessa,"
    s += "CodOcorRetorno,"
    s += "Parcela,"
    s += "TotalParcelas,"
    s += "CodBarras,"
    s += "NumRemessa,"
    s += "Mensagem1,"
    s += "Mensagem2,"
    s += "Mensagem3,"
    s += "Mensagem4,"
    s += "Mensagem5,"
    s += "Mensagem6,"
    s += "Campo1,"
    s += "Campo2,"
    s += "Campo3,"
    s += "Campo4,"
    s += "Campo5,"
    s += "CODREJ1,"
    s += "CODREJ2,"
    s += "CODREJ3,"
    s += "TipDtOcorrencia,"
    s += "DtPgto,"
    s += "VrPago,"
    s += "VrDesEf,"
    s += "VrAcrEf,"
    s += "VrAbaEf,"
    s += "MovManual,"
    s += "Avalista,"
    s += "CPfCGCAval,"
    s += "TipoPessoaAval,"
    s += "NumRem,"
    s += "Lock,"
    s += "CONFIRMA,"
    s += "CARNE,"
    s += "VRJUREF,"
    s += "VRMULEF,"
    s += "VRCREDEF,"
    s += "VRTARIFA,"
    s += "DtCredef,"
    s += "DtTarief,"
    s += "CanalPgto,"
    s += "FormaPgto,"
    s += "FloatPgto"
    s += ")"
    s += " VALUES "
    s += " ("
    s += cod_cedente.to_s
    s += ', "' + cod_sac + '"'
    s += ', "' + self.seu_numero + '"'
    s += ", " + cod_carteira.to_s
    s += ', "' + aceite + '"'
    s += ', "' + cod_especie + '"'
    s += ', ' + inst_cobranca.to_s
    s += ', ' + prazo_prot_dev.to_s
    s += ', "' + opc_vecto + '"'
    s += ', ' + dt_vecto
    s += ', ' + dt_emissao
    s += ', "' + cod_moeda + '"'
    s += ', "' + valor_titulo + '"'
    s += ', "' + valor_juros + '"'
    s += ', ' + dt_desconto
    s += ', "' + valor_desconto + '"'
    s += ', "' + valor_abatimento + '"'
    s += ', ' + dt_multa
    s += ', "' + valor_multa + '"'
    s += ', "' + uso_cedente + '"'
    s += ', "' + nosso_numero.to_s + '"'
    s += ', ' + remessa.to_s
    s += ', ' + retorno.to_s
    s += ', ' + impresso.to_s
    s += ', ' + movimentacao.to_s
    s += ', ' + tipo_bloq.to_s
    s += ', ' + compensavel.to_s
    s += ', "' + cod_ocor_remessa + '"'
    s += ', ' + cod_ocor_retorno
    s += ', ' + parcela
    s += ', ' + total_parcelas
    s += ', ' + cod_barras
    s += ', ' + num_remessa
    s += ', "' + mensagem1 + '"'
    s += ', "' + mensagem2 + '"'
    s += ', "' + mensagem3 + '"'
    s += ', "' + mensagem4 + '"'
    s += ', "' + mensagem5 + '"'
    s += ', "' + mensagem6 + '"'
    s += ', ' + campo1
    s += ', ' + campo2
    s += ', ' + campo3
    s += ', ' + campo4
    s += ', ' + campo5
    s += ', ' + codrej1
    s += ', ' + codrej2
    s += ', ' + codrej3
    s += ', ' + tip_dt_ocorrencia
    s += ', ' + dt_pgto
    s += ', "' + vr_pago + '"'
    s += ', "' + vr_des_ef + '"'
    s += ', "' + vr_acr_ef + '"'
    s += ', "' + vr_aba_ef + '"'
    s += ', ' + mov_manual.to_s
    s += ', ' + avalista
    s += ', ' + cpf_cgc_aval
    s += ', ' + tipo_pessoa_aval.to_s
    s += ', ' + num_rem.to_s
    s += ', ' + lock.to_s
    s += ', ' + confirma.to_s

    s += ', ' + carne.to_s
    s += ', "' + vr_jur_ef + '"'
    s += ', "' + vr_mul_ef + '"'
    s += ', "' + vr_cred_ef + '"'
    s += ', "' + vr_tarifa + '"'

    s += ', ' + dt_cred_ef
    s += ', ' + dt_tari_ef
    s += ', ' + canal_pgto
    s += ', ' + forma_pgto
    s += ', ' + float_pgto
    s += ");\n"

    #printf "%s\n", s
    #@inserts.push(s)

    return s
  end


end

