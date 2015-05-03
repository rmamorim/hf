class CreateCompradors < ActiveRecord::Migration
  def self.up
    create_table :compradors do |t|
      t.integer :ordem
      t.references :pessoa
      t.references :venda

      t.timestamps
    end
  end

  def self.down
    drop_table :compradors
  end
end
