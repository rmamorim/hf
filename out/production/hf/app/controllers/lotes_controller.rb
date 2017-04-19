# coding: utf-8

class LotesController < ApplicationController
  # GET /lotes
  # GET /lotes.xml   
  


  def index
    @area_id = params[:area_id]
    @lotes = Lote.where("area_id = #{@area_id}").order("quadra, numero")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lotes }
    end
    
    #  @action_pages, @actions = paginate :actions, :include => [:project, :context],
    #    :per_page => 5, :order => "actions.description"
    #  @lotes = paginate :lotes, :per_page => 5, :order => "lotes.numero"
  end  
  
  
  # GET /lotes/1
  # GET /lotes/1.xml
  def show
    @lote = Lote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lote }
    end
  end

  
  
  # GET /lotes/new
  # GET /lotes/new.xml
  def new
    @lote = Lote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lote }
    end
  end  
  
  
  # GET /lotes/1/edit
  def edit
    @lote = Lote.find(params[:id])
  end

  # POST /lotes
  # POST /lotes.xml
  def create
    @lote = Lote.new(params[:lote])

    respond_to do |format|
      if @lote.save
        flash[:notice] = 'Lote was successfully created.'
        format.html { redirect_to(@lote) }
        format.xml  { render :xml => @lote, :status => :created, :location => @lote }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lote.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  
  # PUT /lotes/1
  # PUT /lotes/1.xml
  def update
    @lote = Lote.find(params[:id])

    respond_to do |format|
      if @lote.update_attributes(params[:lote])
        flash[:notice] = 'Lote was successfully updated.'
        format.html { redirect_to(@lote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lote.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  
  # DELETE /lotes/1
  # DELETE /lotes/1.xml
  def destroy
    @lotes = Lote.find(params[:id])
    @lotes.destroy

    respond_to do |format|
      format.html { redirect_to(lotes_url) }
      format.xml  { head :ok }
    end
  end
  


  def notas
    @lote = Lote.find(params[:id])
    @notas = Nota.where(["lote_id = (?)", @lote.id])
  end


  def vendas
    @lote = Lote.find(params[:id])
    @vendas = Venda.where(["lote_id = (?)", @lote.id]).order("data_contrato DESC")
  end



  def extrato
    @lote = Lote.find(params[:id])
  end


def imprime_jogo_inicial
  @lote = Lote.find(params[:id])
  @s = Promissoria.new.gera_boletos_iniciais @lote.id
end


def imprime_parcelas_atrasadas
  @lote = Lote.find(params[:id])
  @boletos = Promissoria.new.gera_boletos_parcelas_atrasadas @lote.id
end

  
end
