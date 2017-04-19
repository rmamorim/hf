class AddTipoToIdxpoupancas < ActiveRecord::Migration
  def self.up
    add_column :idxpoupancas, :tipo, :integer
  end

  def self.down
    remove_column :idxpoupancas, :tipo
  end
end
