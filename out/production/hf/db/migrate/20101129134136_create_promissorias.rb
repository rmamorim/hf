class CreatePromissorias < ActiveRecord::Migration
  def self.up
    create_table :promissorias do |t|
      t.integer :num
      t.integer :num_total
      t.boolean :correc_poup
      t.date :data_vencimento
      t.integer :cod_status
      t.integer :cod_tipo_parcela
      t.decimal :valor_original
      t.references :venda

      t.timestamps
    end
  end

  def self.down
    drop_table :promissorias
  end
end
