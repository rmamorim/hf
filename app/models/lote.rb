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

    return self.get_venda.get_status_promissorias
  end



  def get_nome_comprador
    venda = self.get_venda

    if venda.nil?
      return ''
    end

    return venda.compradors[0].pessoa.nome

  end


  def get_preco
    return self.area.get_valor_superficie(self.superficie)
  end



  


  
end
