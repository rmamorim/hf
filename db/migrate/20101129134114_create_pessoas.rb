class CreatePessoas < ActiveRecord::Migration
  def self.up
    create_table :pessoas do |t|
      t.string :cpf
      t.string :identidade
      t.string :identidade_emissor
      t.date :identidade_data
      t.string :profissao
      t.string :estado_civil
      t.string :tratamento
      t.string :nome
      t.string :sexo
      t.string :endereco
      t.string :bairro
      t.string :cidade
      t.string :uf
      t.string :cep
      t.string :telefone
      t.string :celular
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :pessoas
  end
end
