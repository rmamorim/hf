puts "Início"
p = Pessoa.find_by_nome("Vanderson Almeida Corrêa de Sá")

puts "Criando DMJ-3"
###
### DMJ-3
###
sql = "SELECT * FROM Lotes WHERE numero = 3 AND area_id = 31"
r = Lote.find_by_sql sql
loteid = r[0].id
v = Venda.new
v.lote_id = loteid
v.cod_status = Codigo.find_by_status("Escritura - Cláusula resolutiva").id
v.cod_corretor = Codigo.find_by_status("Serra Imóveis").id
v.valor = 333682.32
v.correc_poup = true
v.data_escritura = "2015-07-09"
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
v.insert_grupo_promissorias  1,  1,  1, true, Time.local(2015, 7, 9), Codigo.find_by_status("Entrada").id, 1, 25000.20
v.insert_grupo_promissorias  1, 5, 89, true,  Time.local(2015, 8, 9), Codigo.find_by_status("Mensal").id, 1,  6448.00
v.insert_grupo_promissorias 6, 89, 89, true,  Time.local(2016, 1, 9), Codigo.find_by_status("Mensal").id, 1, 3290.98


puts "Inserindo boletos"
options = {}
options[:data_vencimento] = Date.new(2015, 8, 5)
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


puts "Início"
p = Pessoa.find_by_nome("Vania Moura Pinto")

puts "Criando DUS-H-6"
###
### DUS-H-6
###
sql = "SELECT * FROM Lotes WHERE quadra = 'H' AND numero = 6"
r = Lote.find_by_sql sql
loteid = r[0].id
v = Venda.new
v.lote_id = loteid
v.cod_status = Codigo.find_by_status("Escritura - Cláusula resolutiva").id
v.cod_corretor = Codigo.find_by_status("Serra Imóveis").id
v.valor = 184323.18
v.correc_poup = true
v.data_escritura = "2015-07-07"
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
v.insert_grupo_promissorias  1,  1,  1, true, Time.local(2015, 7, 7), Codigo.find_by_status("Entrada").id, 1, 31618.84
v.insert_grupo_promissorias  1, 84, 84, true,  Time.local(2015, 8, 10), Codigo.find_by_status("Mensal").id, 1,  1817.91


puts "Inserindo boletos"
options = {}
options[:data_vencimento] = Date.new(2015, 8, 5)
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

