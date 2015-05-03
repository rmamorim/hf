# coding: utf-8


class Parcela < ActiveRecord::Base
  
  belongs_to :lote
  
end
