# coding: utf-8

class InadimplenciaController < ApplicationController
  
  
  def index

    @lista = []
    lista = Lote.find_by_sql("select * from lotes where cod_status_access in (1,6)" +
        "order by area_id, numero")

    lista.each do |item|
      @lista.push(item.get_status_promissorias)
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lista }
    end  
  end  
  
end
