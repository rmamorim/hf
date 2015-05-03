

puts "Início"
p = Pessoa.find_by_nome("Constru Imperium Empreendimentos Imobiliários Ltda.")

puts "Criando DUS-A-2."
###
### DUS-A-2
###
sql = "SELECT * FROM Lotes WHERE quadra = 'A' AND numero = 2"
r = Lote.find_by_sql sql
loteid = r[0].id
v = Venda.new
v.lote_id = loteid
v.cod_status = Codigo.find_by_status("Escritura - Cláusula resolutiva").id
v.cod_corretor = Codigo.find_by_status("Sem corretagem").id
v.valor = 121500
v.correc_poup = true
v.data_escritura = "2015-01-29"
v.dias_carencia = 0
v.multa = 2
v.juros = 1
v.tipo_correcao=Codigo.find_by_status("Poupança após MP 567").id
v.periodo_correcao_parcela_mensal = 3
v.primeira_parcela_atualizar = 4
v.save

puts "Criando Comprador"
c = Comprador.new
c.ordem = 1
c.venda_id = v.id
c.pessoa_id = p.id
c.save

puts "Criando Parcelas"
v.insert_grupo_promissorias  1,  1,  1, true, Time.local(2015, 1, 29), Codigo.find_by_status("Mensal").id, 1, 1000.08
v.insert_grupo_promissorias  1, 18, 60, true,  Time.local(2015, 3, 5), Codigo.find_by_status("Mensal").id, 1,  150.00
v.insert_grupo_promissorias 19, 60, 60, true,  Time.local(2016, 9, 5), Codigo.find_by_status("Mensal").id, 1, 2804.76


puts "Inserindo boletos"
options = {}
options[:data_vencimento] = Date.new(2015, 4, 20)
sql = "select * from promissorias where num = 1 AND cod_tipo_parcela = 29 AND venda_id = #{v.id}"
(Promissoria.find_by_sql sql)[0].gera_boleto_vincendo2 options
sql = "select * from promissorias where num = 2 AND cod_tipo_parcela = 29 AND venda_id = #{v.id}"
(Promissoria.find_by_sql sql)[0].gera_boleto_vincendo2 options
sql = "select * from promissorias where num = 3 AND cod_tipo_parcela = 29 AND venda_id = #{v.id}"
(Promissoria.find_by_sql sql)[0].gera_boleto_vincendo2 {}

puts "Lote concuído."


########################################
########################################
########################################


