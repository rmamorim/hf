# coding: utf-8

class Area < ActiveRecord::Base
  
#  has_many :lotes,
#           :class_name => "Area",
#           :foreign_key => "id_area"

   has_many :lotes

  def Area.get_id area
    area = Area.first(:conditions => format("nome = '%s'", area))
    return area.id
  end


   def Area.report_area
     puts "###########"
     dmj = Area.find_by_nome("DMJ")
     dmj.lotes.each do |lote|
       recebido = credito = 0
       vendido = lote.vendido?
       if vendido then
         lote.get_venda.promissorias.each do |p|
           #puts p
           if p.get_situacao == :paga then
             valor = p.get_valor_pago
             puts valor if valor.class == Array
             recebido += valor.to_f
           else
             a = p.get_valores Date.current
             credito += a[:valor_mora]
           end
         end
       end

      puts "#{lote.numero}, #{lote.vendido? ? '1' : '0'}, #{recebido}, #{credito}"
    end
    puts "###########"
  end



  def get_valor_superficie m2

    def get_preco_domus m2
      case
        when m2 < 390
          p = 381.6
        when m2 < 400
          p = 381.55
        when m2 < 410
          p = 381.44
        when m2 < 420
          p = 381.29
        when m2 < 430
          p = 381.1
        when m2 < 440
          p = 380.86
        when m2 < 450
          p = 380.59
        when m2 < 460
          p = 380.28
        when m2 < 470
          p = 379.94
        when m2 < 480
          p = 379.57
        when m2 < 490
          p = 379.17
        when m2 < 500
          p = 378.74
        when m2 < 510
          p = 378.29
        when m2 < 530
          p = 377.82
        when m2 < 540
          p = 376.8
        when m2 < 550
          p = 376.26
        when m2 < 560
          p = 375.7
        when m2 < 570
          p = 375.13
        when m2 < 580
          p = 374.53
        when m2 < 600
          p = 373.92
        when m2 < 640
          p = 372.66
        when m2 < 770
          p = 370.09
        when m2 < 860
          p = 358.04
        when m2 < 1100
          p = 347.4
        when m2 < 1300
          p = 312.13
        else
          p = 282
      end

      return p * m2
    end

    def get_preco_cotia m2
      return get_preco_domus m2
    end

    def get_preco_dmj m2
      return 280 * m2
    end


    case self.nome
      when 'DUS'
        preco = get_preco_domus m2
      when 'DMJ'
        preco = get_preco_dmj m2
      when 'COT'
        preco = get_preco_cotia m2
      else
        preco = 100 * m2
    end

    return preco

  end
  
  
  

end
