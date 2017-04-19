
 RGhost::Document.new :paper => :A4 do |doc|
  doc.show "Meu primeiro relatório PDF no RGhost!"
  doc.next_row 
  doc.grid :data => @pessoas do |g|
    g.column :nome, :align => :left
    g.column :cpf
  end
 end
