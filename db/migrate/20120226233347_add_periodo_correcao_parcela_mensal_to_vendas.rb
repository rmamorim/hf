class AddPeriodoCorrecaoParcelaMensalToVendas < ActiveRecord::Migration
  def self.up
    add_column :vendas, :periodo_correcao_parcela_mensal, :integer
  end

  def self.down
    remove_column :vendas, :periodo_correcao_parcela_mensal
  end
end
