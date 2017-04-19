class CreateNotas < ActiveRecord::Migration
  def self.up
    create_table :notas do |t|
      t.string :titulo
      t.text :mensagem
      t.references :lote

      t.timestamps
    end
  end

  def self.down
    drop_table :notas
  end
end
