# coding: utf-8

class NotasController < ApplicationController
    
  # GET /notas/new
  # GET /notal/new.xml
  def new
    @nota = Nota.new
    @loteid = params[:id]
           
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nota }
    end
  end  
  
  
  
  
  # POST /notas
  # POST /notas.xml
  def create
    @nota = Nota.new(params[:nota])   
    
    #@nota.lote_id = 172
    
    respond_to do |format|
      if @nota.save
        flash[:notice] = 'Nota was successfully created.'
        format.html { redirect_to(@nota) }
        format.xml  { render :xml => @nota, :status => :created, :location => @nota }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nota.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  

  # GET /notas/1
  # GET /notas/1.xml
  def show
    @nota = Nota.find(params[:id])
        
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nota }
    end
  end
  
  
end
