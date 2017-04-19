# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150407194325) do

  create_table "_vendas_old_20120226", :force => true do |t|
    t.integer  "cod_status"
    t.integer  "cod_corretor"
    t.decimal  "valor"
    t.boolean  "correc_poup"
    t.date     "data_contrato"
    t.date     "data_escritura"
    t.integer  "dias_carencia"
    t.decimal  "multa"
    t.decimal  "juros"
    t.integer  "tipo_correcao"
    t.integer  "lote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "periodo_correcao_parcela_mensal"
  end

  create_table "areas", :force => true do |t|
    t.string   "nome"
    t.decimal  "superficie"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "boletos", :force => true do |t|
    t.integer  "status"
    t.string   "nosso_numero"
    t.integer  "cod_sac"
    t.string   "seu_numero"
    t.date     "data_vencimento"
    t.date     "data_emissao"
    t.decimal  "valor_original"
    t.decimal  "atualizacao"
    t.decimal  "perc_poup"
    t.decimal  "valor_titulo"
    t.decimal  "valor_multa"
    t.decimal  "valor_juros"
    t.string   "mensagem1"
    t.string   "mensagem2"
    t.string   "mensagem3"
    t.string   "mensagem4"
    t.string   "mensagem5"
    t.string   "mensagem6"
    t.integer  "tipo"
    t.integer  "promissoria_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "impresso"
    t.boolean  "gerado_sql"
    t.decimal  "desconto"
    t.integer  "dias_atraso"
    t.decimal  "valor_vencimento"
    t.decimal  "juros_desde_vencimento"
    t.decimal  "multa_desde_vencimento"
    t.integer  "dias_permitido_receber"
  end

  create_table "categorias", :force => true do |t|
    t.string   "categoria"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "codigos", :force => true do |t|
    t.string   "status"
    t.integer  "ordem"
    t.integer  "categoria_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "compradors", :force => true do |t|
    t.integer  "ordem"
    t.integer  "pessoa_id"
    t.integer  "venda_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "idxpoupancas", :force => true do |t|
    t.date     "mes"
    t.decimal  "indice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tipo"
  end

  create_table "iptus", :force => true do |t|
    t.decimal  "ano"
    t.decimal  "valor_imposto"
    t.decimal  "valor_taxa"
    t.decimal  "valor_tsu"
    t.decimal  "valor_total"
    t.string   "titular"
    t.boolean  "pago"
    t.decimal  "multa"
    t.decimal  "juros"
    t.boolean  "da"
    t.integer  "lote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lotes", :force => true do |t|
    t.integer  "numero"
    t.string   "subdivisao"
    t.decimal  "superficie"
    t.decimal  "inscricao_pmg"
    t.integer  "cod_cliente_access"
    t.integer  "cod_vendedor_access"
    t.integer  "cod_status_access"
    t.integer  "area_access"
    t.integer  "qtd_p_entrada"
    t.decimal  "valor_p_entrada"
    t.integer  "qtd_p1"
    t.decimal  "valor_p1"
    t.integer  "qtd_p2"
    t.decimal  "valor_p2"
    t.date     "data_contrato"
    t.date     "data_primeira_parcela"
    t.decimal  "valor_total"
    t.boolean  "rubrica_comprador"
    t.text     "comentario"
    t.string   "cod_sacado"
    t.integer  "area_id"
    t.integer  "cliente_id"
    t.integer  "vendedor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "quadra"
  end

  create_table "notas", :force => true do |t|
    t.string   "titulo"
    t.text     "mensagem"
    t.integer  "lote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pagamentos", :force => true do |t|
    t.integer  "status"
    t.decimal  "valor_titulo"
    t.decimal  "valor_multa"
    t.decimal  "valor_juros"
    t.decimal  "valor_desconto"
    t.decimal  "valor_tarif_banco"
    t.decimal  "valor_pago"
    t.date     "data_pagamento"
    t.date     "data_processamento"
    t.text     "comentarios"
    t.integer  "boleto_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pessoas", :force => true do |t|
    t.string   "cpf"
    t.string   "identidade"
    t.string   "identidade_emissor"
    t.date     "identidade_data"
    t.string   "profissao"
    t.string   "estado_civil"
    t.string   "tratamento"
    t.string   "nome"
    t.string   "sexo"
    t.string   "endereco"
    t.string   "bairro"
    t.string   "cidade"
    t.string   "uf"
    t.string   "cep"
    t.string   "telefone"
    t.string   "celular"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promissorias", :force => true do |t|
    t.integer  "num"
    t.integer  "num_total"
    t.boolean  "correc_poup"
    t.date     "data_vencimento"
    t.integer  "cod_status"
    t.integer  "cod_tipo_parcela"
    t.decimal  "valor_original"
    t.integer  "venda_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retornos", :force => true do |t|
    t.decimal  "valor"
    t.decimal  "tarifa"
    t.decimal  "encargos"
    t.decimal  "descontos"
    t.decimal  "abatimento"
    t.decimal  "credito"
    t.date     "data_vencimento"
    t.date     "data_pagamento"
    t.date     "data_credito"
    t.string   "nosso_numero"
    t.string   "dados_pagamento"
    t.string   "arquivo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sqlite_stat1" because of following StandardError
#   Unknown type '' for column 'tbl'

  create_table "vendas", :force => true do |t|
    t.integer  "cod_status"
    t.integer  "cod_corretor"
    t.decimal  "valor"
    t.boolean  "correc_poup"
    t.date     "data_contrato"
    t.date     "data_escritura"
    t.integer  "dias_carencia"
    t.decimal  "multa"
    t.decimal  "juros"
    t.integer  "tipo_correcao"
    t.integer  "lote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "periodo_correcao_parcela_mensal", :default => 12
    t.integer  "primeira_parcela_atualizar"
  end

end
