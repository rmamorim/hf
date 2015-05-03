# coding: utf-8


class Comprador < ActiveRecord::Base
  
  belongs_to :venda
  belongs_to :pessoa
  
end
