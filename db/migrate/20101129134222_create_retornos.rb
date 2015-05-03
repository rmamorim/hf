class CreateRetornos < ActiveRecord::Migration
  def self.up
    create_table :retornos do |t|
      t.decimal :valor
      t.decimal :tarifa
      t.decimal :encargos
      t.decimal :descontos
      t.decimal :abatimento
      t.decimal :credito
      t.date :data_vencimento
      t.date :data_pagamento
      t.date :data_credito
      t.string :nosso_numero
      t.string :dados_pagamento
      t.string :arquivo

      t.timestamps
    end
  end

  def self.down
    drop_table :retornos
  end
end
