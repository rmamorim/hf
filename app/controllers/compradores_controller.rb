# coding: utf-8

class CompradoresController < ApplicationController
  #active_scaffold :comprador


  def index
    @venda = Venda.find(params[:venda])
    @compradores = Comprador.find(:all, :conditions => "venda_id = '#{@venda.id}'", :order => "ordem")
  end


  def create
    venda = Venda.find(params[:id])
    params[:comprador][:venda_id] = params[:id]
    params[:comprador][:ordem] = venda.compradors.size + 1
    @comprador = Comprador.create(params[:comprador])

		flash[:notice] = 'Comprador adicionado com sucesso!'
		redirect_to :controller=>"compradores", :action => "index", :venda => params[:id]
  end


  def destroy
    @comprador = Comprador.find(params[:id])
    venda = @comprador.venda
    @comprador.destroy

    flash[:notice] = 'Comprador retirado com sucesso!'
		redirect_to :controller=>"compradores", :action => "index", :venda => venda
  end


end
