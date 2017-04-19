

cod_tipo_parcela = 27  # Entrada
lotes_id = [183,184,189,190,191,192,193,197,198,199,200,201,203,204,205,208,209,210,211]
valores_entrada = [9500,9500,11000,9500,9500,9500,9500,10200,10200,10600,9500,9500,9500,9500,9500,4750,9500,25714.90,9500]

(0..lotes_id.size-1).each do |i|
  puts "#{lotes_id[i]} - #{valores_entrada[i]}"

  lote = Lote.find(lotes_id[i])
  venda = lote.get_venda
  data_vencimento = venda.get_data_venda

  promissoria = venda.insert_grupo_promissorias 1, 1, 1, true, data_vencimento, cod_tipo_parcela, 1, valores_entrada[i]
  promissoria.faz_pagamento_entrada_sem_boleto valores_entrada[i]

end





