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

  
  
  

end
