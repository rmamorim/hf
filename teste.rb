Venda.find(793).promissorias.each do |p| 
	puts '######'
	puts p
	#puts p.cod_tipo_parcela
	#puts p.data_vencimento
	#puts p.data_vencimento.day
	if (p.cod_tipo_parcela && p.num >= 14)
		puts "Alterar dia"
		#p.data_vencimento = "#{p.data_vencimento.year}-#{p.data_vencimento.month}-22"
		#p.save
	end
	
	if (p.cod_tipo_parcela && p.num >= 14 && p.num <= 24)
		puts "Gerar boleto"
		p.gera_boleto_automatico
	end
end