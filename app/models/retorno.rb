# coding: utf-8
require 'win32ole'
require 'fileutils'
require 'digest'
require 'rubygems'
require 'pathname'
require 'active_record'
require 'csv'
require 'rexml/document'
require 'sqlite3'
require 'benchmark'


class Retorno < ActiveRecord::Base
  #belongs_to :pagamento


  def Retorno.get_retorno nosso_numero
    retorno = Retorno.find_by_nosso_numero(nosso_numero)
    return retorno
  end





  def Retorno.get_retorno_cobranca
    a = []
    e = []

    ret_idx = {}
    ret = Retorno.find_by_sql("select distinct nosso_numero, arquivo from retornos")
    for idx in ret do
      if !ret_idx.key?(idx.nosso_numero.strip) then
        ret_idx[idx.nosso_numero.strip] = idx.arquivo
      end
    end



    sql = <<sql_type
SELECT
  stituNumDoc,
  stituNossoNum,
  ttituDtDoc,
  ttituDtVcto,
  ttituDtOco,
  stituNumRem,
  FloatPgto,
  FormaPgto,
  CanalPgto,
  DtTariEf,
  DtCredEf,
  dtituValTarifa,
  dtituValCredEf,
  dtituValAcrEf,
  dtituValPgto,
  dtituValDoc
FROM tabTitulos
WHERE stituCodRet = '06'
ORDER BY ttituDtOco
sql_type


    arq = "C:\\Dropbox\\Cobranca\\Cobranca\\BDSINCO.mdb"
    password = "CEF104"
    @cnn = WIN32OLE.new('ADODB.Connection')
    @cnn.Open("Provider=Microsoft.Jet.OLEDB.4.0;Jet OLEDB:Database Password=#{password};Data Source=#{arq}")
    @rs = WIN32OLE.new('ADODB.Recordset')

    @rs.Open(sql, @cnn)
    if !@rs.EOF then
      data = @rs.GetRows.transpose if !@rs.EOF

      data.each do |linha|
        ##
        ##
        #@valores["stituNossoNum"] = '91' + row[columns.index("nosso_numero")][-13..-1].strip.rjust(13, '0')
        nosso_numero = '800' + (linha[1]).strip[-13..-1]
        #puts nosso_numero

        boleto = Boleto.first(:conditions => 'nosso_numero = ' + nosso_numero )
        if !boleto.nil? then
          ## Boletos TEM nosso_numero
          ##

          if !ret_idx.key?(nosso_numero) then
            ### Retornos NÃO tem nosso_numero
            ###
            retorno = Retorno.new
            retorno.tarifa = linha[11]
            retorno.valor = linha[15]     # valor_titulo
            retorno.data_vencimento = linha[3]
            retorno.nosso_numero = nosso_numero
            retorno.dados_pagamento = (linha[8]).strip + (linha[7]).strip + (linha[6]).strip
            retorno.arquivo = linha[5]
            retorno.encargos = linha[13]    # encargos
            retorno.descontos = 0    # desconto
            retorno.abatimento = 0    # abatimento
            retorno.credito = linha[12]   # credito_bruto
            retorno.data_pagamento = linha[4]
            retorno.data_credito = linha[10]
            retorno.save

            #if boleto.status != 39 then  # 39 = Título pago
              ### O boleto não estava pago.
              ###
              msg = format('Titulo %s com status = %s.', boleto.seu_numero, boleto.status)
              e.push msg
              e.push Pagamento::boleto_pago boleto, retorno
            #end

            b = []
            b.push boleto.seu_numero
            b.push boleto.data_vencimento.to_s
            b.push retorno.data_pagamento.to_s[0..9]
            b.push boleto.valor_original.to_s
            b.push boleto.valor_titulo.to_s
            b.push((retorno.tarifa.to_f + retorno.credito.to_f).round(2).to_s)
            a.push b
            puts "#{boleto.promissoria.venda.lote.to_label.rjust(8, ' ')}-#{boleto.promissoria.num.to_s.ljust(3, ' ')}: #{linha[4].to_s[0..9]} : #{(linha[14] - linha[11]).round(2).to_s.rjust(9, ' ')} : #{boleto.promissoria.cod_tipo_parcela}"

          else
            ### Retorno TEM nosso_numero
            ###

            if ret_idx[nosso_numero].to_s != linha[5].to_s then
              ## arquivos diferentes = pagamento em duplicidade
              ##
              retorno = Retorno.new
              retorno.tarifa = linha[11]
              retorno.valor = linha[15]     # valor_titulo
              retorno.data_vencimento = linha[3]
              retorno.nosso_numero = nosso_numero
              retorno.dados_pagamento = (linha[8]).strip + (linha[7]).strip + (linha[6]).strip
              retorno.arquivo = linha[5]
              retorno.encargos = linha[13]    # encargos
              retorno.descontos = 0    # desconto
              retorno.abatimento = 0    # abatimento
              retorno.credito = linha[12]   # credito_bruto
              retorno.data_pagamento = linha[4]
              retorno.data_credito = linha[10]
              retorno.save

              msg = format('### Pagamento em duplicidade ###. Titulo %s com status = %s.', boleto.seu_numero, boleto.status)
              e.push msg
              e.push Pagamento::boleto_pago boleto, retorno

              b = []
              b.push boleto.seu_numero
              b.push boleto.data_vencimento.to_s
              b.push retorno.data_pagamento.to_s[0..9]
              b.push boleto.valor_original.to_s
              b.push boleto.valor_titulo.to_s
              b.push((retorno.tarifa.to_f + retorno.credito.to_f).round(2).to_s)
              a.push b
              puts "#{boleto.promissoria.venda.lote.to_label.rjust(8, ' ')}-#{boleto.promissoria.num.to_s.ljust(3, ' ')}: #{linha[4].to_s[0..9]} : #{(linha[14] - linha[11]).round(2).to_s.rjust(9, ' ')} : #{boleto.promissoria.cod_tipo_parcela}"

            end
          end

        else
          ## Boletos NÃO tem nosso_numero
          ##
          puts '### NÃO tem boleto!!!'
          msg = "Nosso_numero #{nosso_numero} nao encontrado em Boletos!!!"
          e.push msg
        end
      end
    end

    return [a,e]
  end



  def Retorno.get_retorno_SICOB
    #path = '/home/ricardo/hansafly/Caixa/CobCAIXA/Seguranc/'
    path = "C:\\Caixa\\CobCAIXA\\Seguranc\\"

    arquivos = []
    ret_arquivos = Retorno.find_by_sql("select distinct arquivo from retornos")
    for arq in ret_arquivos do
      arquivos.push(arq.arquivo)
    end
    logger.info(">>> Lidos um total de #{ret_arquivos.size} registros!")

    a = []
    e = []
    retorno = nil

    logger.info(">>> Antes! <<<")
    Dir.chdir(path)
    logger.info(">>> Depois! <<<")

    for arq in Dir.glob('*.ret') do
      logger.info(">>> arquivo: #{arq} <<<")
      if not [".", ".."].include?(arq) then
        if ! arquivos.include?(arq) then
          logger.info ">>> Lendo o arquivo <#{arq}>."
          IO.readlines(arq).each do |line|
            controle_registro = line[7,1]
            segmento = line[13,1]

            case controle_registro.to_i
              when 0
                tipo = 'Header do arquivo'
              when 1
                tipo = 'Header do lote'
              when 3
                tipo = 'Detalhe'
                if segmento == 'T' then
                  tipo = 'Segmento T'
                  retorno = Retorno.new
                  retorno.tarifa = Biblioteca::moeda_cef_to_sql(line[198,15])
                  retorno.valor = Biblioteca::moeda_cef_to_sql(line[81,15])     # valor_titulo
                  retorno.data_vencimento = Biblioteca::data_cef_to_sql(line[73,8])
                  retorno.nosso_numero = line[148,40]
                  retorno.dados_pagamento = line[213,10]
                  retorno.arquivo = arq.strip
                end
                if segmento == 'U' then
                  #
                  # aqui faz a insercao do registro retorno
                  #
                  tipo = 'Segmento U'
                  retorno.encargos = Biblioteca::moeda_cef_to_sql(line[17,15])    # encargos
                  retorno.descontos = Biblioteca::moeda_cef_to_sql(line[32,15])    # desconto
                  retorno.abatimento = Biblioteca::moeda_cef_to_sql(line[47,15])    # abatimento
                  retorno.credito = Biblioteca::moeda_cef_to_sql(line[92,15])    # credito_bruto
                  retorno.data_pagamento = Biblioteca::data_cef_to_sql(line[137,8])
                  retorno.data_credito = Biblioteca::data_cef_to_sql(line[145,8])
                  retorno.save

                  logger.info ">>> Procurando boleto com nosso_numero = #{retorno.nosso_numero.strip}."
                  boleto = Boleto.find(:first, :conditions => 'nosso_numero = ' + retorno.nosso_numero.strip )

                  if !boleto.nil? then
                    logger.info ">>> Encontrou."
                    if boleto.status != 39 then
                      msg = format('Titulo %s com status = %s.', boleto.seu_numero, boleto.status)
                      e.push msg
                      e.push Pagamento::boleto_pago boleto, retorno
                    end

                    b = []
                    b.push boleto.seu_numero
                    b.push boleto.data_vencimento.to_s
                    b.push retorno.data_pagamento.to_s
                    b.push boleto.valor_original.to_s
                    b.push boleto.valor_titulo.to_s
                    b.push(retorno.tarifa.to_f + retorno.credito.to_f).to_s
                    a.push b
                  else
                    logger.info ">>> Não encontrou!!!"
                    msg = 'nosso_numero nao encontrado = ' + retorno.nosso_numero.strip
                    e.push msg
                  end
                end
              when 5
                tipo = 'Trailer do lote'
              when 9
                tipo = 'Trailer do arquivo'
              else
                tipo = controle_registro.to_i
            end
          end
        end
      end
    end

    return [a,e]

  end



end
