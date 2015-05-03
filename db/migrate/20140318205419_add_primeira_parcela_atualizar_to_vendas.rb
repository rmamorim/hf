class AddPrimeiraParcelaAtualizarToVendas < ActiveRecord::Migration
  def self.up
    add_column :vendas, :primeira_parcela_atualizar, :integer
  end

  def self.down
    remove_column :vendas, :primeira_parcela_atualizar
  end
end
