class CreateVendas < ActiveRecord::Migration
  def self.up
    create_table :vendas do |t|
      t.integer :cod_status
      t.integer :cod_corretor
      t.decimal :valor
      t.boolean :correc_poup
      t.date :data_contrato
      t.date :data_escritura
      t.integer :dias_carencia
      t.decimal :multa
      t.decimal :juros
      t.integer :tipo_correcao
      t.references :lote

      t.timestamps
    end
  end

  def self.down
    drop_table :vendas
  end
end
