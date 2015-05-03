
#=>[top,right,bottom,left]
RGhost::Document.new :paper => :letter, :margin => [0.5, 1, 0.5, 2], :encoding => 'IsoLatin'  do |doc|


  h = 27.94
  c = 21.59

  he = 3.39
  ce = 10.16

  ms = 2.105
  ml = 0.4233333

  mse = 1
  mle = 1
  esp_lin = 0.254 * 2

  doc.define_tags do
    tag :font1, :name => 'TimesBold', :size => 12, :color => '#000000'
    tag :font2, :name => 'Times', :size => 12, :color => '#000000'
  end


  lin = 0
  col = 0

  for lote in @lotes do
    doc.show "Lote: #{lote.to_label}"
    doc.next_row
    doc.show "Status: #{Codigo::get_status(lote.cod_status_access)}"
    doc.next_row

    doc.show "Superfície: #{lote.superficie}"
    doc.next_row

    doc.show "Inscrião PMG: #{lote.inscricao_pmg}"
    doc.next_row

    doc.show "Comprador: #{lote.get_nome_comprador}"
    doc.next_row

#    doc.show "Data do contrato: #{Biblioteca::format_data(lote.get_venda.get_data_venda)}"
#    doc.next_row

    doc.show "Data do contrato: #{lote.get_venda}"
    doc.next_row


#    doc.show "Valor: #{Biblioteca::format_currency lote.valor_total}"
#    doc.next_row

#    doc.show "Entrada: #{Biblioteca.format_entrada lote.qtd_p_entrada, lote.valor_p_entrada}"
#    doc.next_row

#    doc.show "Parcelas: #{lote.get_venda.get_num_parcelas}"
#    doc.next_row




    doc.next_page    
  end

end
