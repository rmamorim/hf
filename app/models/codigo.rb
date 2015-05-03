# coding: utf-8


class Codigo < ActiveRecord::Base
  
  belongs_to :categoria

  def to_label
    "Código: #{status}"
  end

  
  def Codigo.get_status id
    cod = Codigo.first(:conditions => format("id = %s", id))
    return cod.status
  end

end






