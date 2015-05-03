class CreateLotes < ActiveRecord::Migration
  def self.up
    create_table :lotes do |t|
      t.decimal :numero
      t.string :subdivisao
      t.decimal :superficie
      t.decimal :inscricao_pmg
      t.integer :cod_cliente_access
      t.integer :cod_vendedor_access
      t.integer :cod_status_access
      t.integer :area_access
      t.integer :qtd_p_entrada
      t.decimal :valor_p_entrada
      t.integer :qtd_p1
      t.decimal :valor_p1
      t.integer :qtd_p2
      t.decimal :valor_p2
      t.date :data_contrato
      t.date :data_primeira_parcela
      t.decimal :valor_total
      t.boolean :rubrica_comprador
      t.text :comentario
      t.string :cod_sacado
      t.references :area
      t.integer :cliente_id
      t.integer :vendedor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :lotes
  end
end
