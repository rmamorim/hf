# coding: utf-8

class RetornoController < ApplicationController

  
  def index
    dados = Retorno::get_retorno_SICOB
    @a = dados[0]
    @e = dados[1]
  end


  def cobranca
    dados = Retorno::get_retorno_cobranca
    @a = dados[0]
    @e = dados[1]
  end



end
