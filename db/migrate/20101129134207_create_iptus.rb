class CreateIptus < ActiveRecord::Migration
  def self.up
    create_table :iptus do |t|
      t.decimal :ano
      t.decimal :valor_imposto
      t.decimal :valor_taxa
      t.decimal :valor_tsu
      t.decimal :valor_total
      t.string :titular
      t.boolean :pago
      t.decimal :multa
      t.decimal :juros
      t.boolean :da
      t.references :lote

      t.timestamps
    end
  end

  def self.down
    drop_table :iptus
  end
end
