# coding: utf-8


class Retorno < ActiveRecord::Base
  #belongs_to :pagamento


  def Retorno.get_retorno nosso_numero
    retorno = Retorno.find_by_nosso_numero(nosso_numero)
    return retorno
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
