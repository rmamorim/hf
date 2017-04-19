# coding: utf-8

class PessoasController < ApplicationController


  def index
    @pessoas = Pessoa.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end


  def new
    @pessoa = Pessoa.new
    @venda_id = params[:venda]
  end


  def create
    @pessoa = Pessoa.create(params[:pessoa])
    flash[:notice] = "['#{@pessoa.nome}'] foi criado com sucesso."
    redirect_to :controller=>"compradores", :action => "index", :venda => params[:venda_id]
  end


end
