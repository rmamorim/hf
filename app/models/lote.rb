# coding: utf-8


class Lote < ActiveRecord::Base
   
  has_many :notas
  has_many :iptus
  #has_many :parcelas
  has_many :vendas
  belongs_to :area

  #  belongs_to :area,
  #           :class_name => "Lote",
  #           :foreign_key => "id_area"




  def to_label
    if quadra.nil? then
      "#{area.nome}-#{numero.to_i}"
    else
      "#{area.nome}-#{quadra}-#{numero.to_i}"
    end
  end 




  def get_venda
    ##
    ## Levar em consideração cod_status
    ##

    vendas = Venda.find(:all,
      :conditions => format("lote_id = #{self.id}"),
      :order => 'id'
    )

    vendas.each do |venda|
      if venda.venda_valida? then
        return venda
      end
    end

    return nil
  end


  def vendido?
    flag_vendido = false
    for v in self.vendas
      flag_vendido = true if [51,52,53,55,65].include?(v.cod_status)
    end
    return flag_vendido
  end




  def get_status_promissorias
    i = 0

    # array
    # 0 - pagas
    # 1 - vincendas
    # 2 - atrasadas
    # 3 - > 90 dias
    # 4 - outros


    i_mensal = 0
    i_intermediaria = 0
    i_entrada = 0
    a_mensal = [0,0,0,0,0]
    a_entrada = [0,0,0,0,0]
    a_intermediaria = [0,0,0,0,0]
    a_geral = [0,0,0,0,0]



    venda = self.get_venda
    promissorias = venda.promissorias
    for p in promissorias do
      case p.cod_tipo_parcela

        ##
        ##  Entrada
        ##
      when 27
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
        ##  Mensal
        ##
      when 29
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
    a.push self
    a.push i_entrada
    a.push i_mensal
    a.push i_intermediaria
    a.push a_entrada
    a.push a_mensal
    a.push a_intermediaria
    a.push a_geral

    return a

  end



  def get_nome_comprador
    venda = self.get_venda

    if venda.nil?
      return ''
    end

    return venda.compradors[0].pessoa.nome

  end



 

  


  
end
