class AddDiasPermitidoReceberToBoletos < ActiveRecord::Migration
  def self.up
    add_column :boletos, :dias_permitido_receber, :integer
  end

  def self.down
    remove_column :boletos, :dias_permitido_receber
  end
end
