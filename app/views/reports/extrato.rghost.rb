#=>[top,right,bottom,left]
RGhost::Document.new :paper => :A4, :margin => [0.5, 1, 0.5, 2], :encoding => 'IsoLatin'  do |doc|


  doc.define_tags do
    tag :font1, :name => 'TimesBold', :size => 12, :color => '#000000'
    tag :font2, :name => 'Times', :size => 8, :color => '#120034'
  end



  venda = @lote.get_venda
  if !venda.nil?
    dados = venda.get_extrato
  end
  lote = @lote
  
#  doc.show "Lote: #{lote.to_label}"
#  doc.next_row
#  doc.show "Status: #{Codigo::get_status(lote.cod_status_access)}"
#  doc.next_row
#
#  doc.show "Superfície: #{lote.superficie}"
#  doc.next_row
#
#  doc.show "Inscrião PMG: #{lote.inscricao_pmg}"
#  doc.next_row
#
#  doc.show "Comprador: #{lote.get_nome_comprador}"
#  doc.next_row
#
#  #    doc.show "Data do contrato: #{Biblioteca::format_data(lote.get_venda.get_data_venda)}"
#  #    doc.next_row
#
#  doc.show "Data do contrato: #{Biblioteca::format_data(@lote.get_venda.get_data_venda)}"
#  doc.next_row
#
#  doc.next_row
#  doc.next_row


  ##


  grid = RGhost::Grid::Matrix.new
  grid.style(:border_lines)

  grid.header.after_create do |a|
    a.use_tag :font2
  end

  grid.even_column do |r|
    r.background_row(:size => grid.width)
  end

  


##
##

  titulos = dados[:titulos]
  titulos.each do |t|
    grid.column :title => t
  end

##
##

  values = []
  linhas = dados[:linhas]
  linhas.each do |linha|
    values.push linha
  end

  ##
  ##

  grid.data(values)
  doc.set grid






end
