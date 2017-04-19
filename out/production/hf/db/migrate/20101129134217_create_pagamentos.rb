class CreatePagamentos < ActiveRecord::Migration
  def self.up
    create_table :pagamentos do |t|
      t.integer :status
      t.decimal :valor_titulo
      t.decimal :valor_multa
      t.decimal :valor_juros
      t.decimal :valor_desconto
      t.decimal :valor_tarif_banco
      t.decimal :valor_pago
      t.date :data_pagamento
      t.date :data_processamento
      t.text :comentarios
      t.references :boleto

      t.timestamps
    end
  end

  def self.down
    drop_table :pagamentos
  end
end
