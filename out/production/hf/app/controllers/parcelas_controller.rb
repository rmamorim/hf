# coding: utf-8

class ParcelasController < ApplicationController
    
  def index
    @parcelas = Parcela.order("parcelas.id")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @parcelas }
    end  
  end
  
  
  # GET /parcelas/1
  # GET /parcelas/1.xml
  def show
    @parcela = Parcela.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @parcela }
    end
  end
  
  
  
  # GET /parcelas/1/edit
  def edit
    @parcela = Parcela.find(params[:id])
  end  
  
  
  # PUT /parcelas/1
  # PUT /parcelas/1.xml
  def update
    @parcela = Parcela.find(params[:id])

    respond_to do |format|
      if @parcela.update_attributes(params[:parcela])
        flash[:notice] = 'Parcela was successfully updated.'
        format.html { redirect_to(@parcela) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @parcela.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  
  
  
  end
