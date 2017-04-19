class CreateBoletos < ActiveRecord::Migration
  def self.up
    create_table :boletos do |t|
      t.integer :status
      t.string :nosso_numero
      t.integer :cod_sac
      t.string :seu_numero
      t.date :data_vencimento
      t.date :data_emissao
      t.decimal :valor_original
      t.decimal :atualizacao
      t.decimal :perc_poup
      t.decimal :valor_titulo
      t.decimal :valor_multa
      t.decimal :valor_juros
      t.string :mensagem1
      t.string :mensagem2
      t.string :mensagem3
      t.string :mensagem4
      t.string :mensagem5
      t.string :mensagem6
      t.integer :tipo
      t.references :promissoria

      t.timestamps
    end
  end

  def self.down
    drop_table :boletos
  end
end
