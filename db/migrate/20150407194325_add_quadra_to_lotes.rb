class AddQuadraToLotes < ActiveRecord::Migration
  def self.up
    add_column :lotes, :quadra, :string
  end

  def self.down
    remove_column :lotes, :quadra
  end
end
