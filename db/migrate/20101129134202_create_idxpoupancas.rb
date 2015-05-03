class CreateIdxpoupancas < ActiveRecord::Migration
  def self.up
    create_table :idxpoupancas do |t|
      t.date :mes
      t.decimal :indice

      t.timestamps
    end
  end

  def self.down
    drop_table :idxpoupancas
  end
end
