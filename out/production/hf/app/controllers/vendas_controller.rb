# coding: utf-8

class VendasController < ApplicationController
  #active_scaffold :venda

  def edit
    @venda = Venda.find(params[:id])
  end


  def show
    @venda = Venda.find(params[:id])
  end


  def update
    @venda = Venda.find(params[:id])

    respond_to do |format|
      if @venda.update_attributes(params[:venda])
        flash[:notice] = 'Venda foi atualizada com sucesso!'
        format.html { redirect_to(@venda.lote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @venda.errors, :status => :unprocessable_entity }
      end
    end
  end



  def new
    #@venda = Venda.new
    @lote = Lote.find(params[:lote])
  end



  def create
    pessoa_id = params[:venda][:pessoa_id]
    params[:venda].delete(:pessoa_id)

    @venda = Lote.find(params[:id]).vendas.create(params[:venda])

    @comprador = Comprador.new
    @comprador.ordem = 1
    @comprador.pessoa_id = pessoa_id
    @comprador.venda_id = @venda.id
    @comprador.save

		flash[:notice] = 'Venda adicionado com sucesso!'
		redirect_to :controller=>"lotes", :action => "vendas", :id => params[:id]

  end


  def cadastra
    @venda = Venda.find(params[:id])
  end

  def novo_grupo_promissorias
    @grupo_promissorias = (params[:grupo_promissorias])
    dia = @grupo_promissorias["data_inicial(3i)"]
    mes = @grupo_promissorias["data_inicial(2i)"]
    ano = @grupo_promissorias["data_inicial(1i)"]
    @data_inicial = Time.local(ano.to_i, mes.to_i, dia.to_i)

    venda = Venda.find(params[:id])
    venda.insert_grupo_promissorias \
      @grupo_promissorias[:inicio_intervalo], \
      @grupo_promissorias[:fim_intervalo], \
      @grupo_promissorias[:total_intervalo], \
      @grupo_promissorias[:corrigida], \
      @data_inicial, \
      @grupo_promissorias[:cod_tipo_promissoria], \
      @grupo_promissorias[:periodo], \
      @grupo_promissorias[:valor]

   redirect_to(:controller => 'vendas', :action => 'show', :id => venda.id)

  end

end
