

p = Pessoa.find_by_nome("Constru Imperium Empreendimentos Imobiliários Ltda.")
puts p.id

sql = "SELECT * FROM Lotes WHERE numero = 2 AND quadra = 'A'"
l = Lote.find_by_sql sql
puts l.size
puts l[0].id

### 830

options = {}
options[:data_vencimento] = Date.new(2015, 4, 20)
sql = "select * from promissorias where num = 1 AND cod_tipo_parcela = 29 AND venda_id = 830"
(Promissoria.find_by_sql sql)[0].gera_boleto_vincendo2 options



