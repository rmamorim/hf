class CreateCodigos < ActiveRecord::Migration
  def self.up
    create_table :codigos do |t|
      t.string :status
      t.integer :ordem
      t.references :categoria

      t.timestamps
    end
  end

  def self.down
    drop_table :codigos
  end
end
