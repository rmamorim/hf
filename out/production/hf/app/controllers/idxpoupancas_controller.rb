# coding: utf-8

class IdxpoupancasController < ApplicationController
  #active_scaffold :idxpoupanca
  
  def calcula
    @dados = params[:idxpoupanca]

    if !@dados.nil? then
      valor_inicial = @dados[:valor]
      dia = @dados["data_inicio(3i)"]
      mes = @dados["data_inicio(2i)"]
      ano = @dados["data_inicio(1i)"]
      data_inicio = Time.local(ano.to_i, mes.to_i, dia.to_i)
      dia = @dados["data_fim(3i)"]
      mes = @dados["data_fim(2i)"]
      ano = @dados["data_fim(1i)"]
      data_fim = Time.local(ano.to_i, mes.to_i, dia.to_i)

      @idx = Idxpoupanca::calcula_indice_entre_datas(data_inicio, data_fim, 45)
      @valor = @idx.to_f * (valor_inicial).to_f

      @idx_mp = Idxpoupanca::calcula_indice_entre_datas(data_inicio, data_fim, 66)
      @valor_mp = @idx_mp.to_f * (valor_inicial).to_f

    end
  end

end
