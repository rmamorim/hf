# coding: utf-8

class Cliente < ActiveRecord::Base
  
  has_many :lotes
  
end
