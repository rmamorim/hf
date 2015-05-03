class AddColunasToBoletos < ActiveRecord::Migration
  def self.up
	add_column :boletos, :impresso, :boolean
	add_column :boletos, :gerado_sql, :boolean
	add_column :boletos, :desconto, :decimal
	add_column :boletos, :dias_atraso, :integer
	add_column :boletos, :valor_vencimento, :decimal
	add_column :boletos, :juros_desde_vencimento, :decimal
	add_column :boletos, :multa_desde_vencimento, :decimal
  end

  def self.down
	remove_column :boletos, :impresso
	remove_column :boletos, :gerado_sql
	remove_column :boletos, :desconto
	remove_column :boletos, :dias_atraso
	remove_column :boletos, :valor_vencimento
	remove_column :boletos, :juros_desde_vencimento
	remove_column :boletos, :multa_desde_vencimento
  end
end
