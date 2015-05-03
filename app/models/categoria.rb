# coding: utf-8

class Categoria < ActiveRecord::Base
  
  has_many :codigos
  
  def to_label
    "Categoria: #{categoria}"
  end  
  
  
end
