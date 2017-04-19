
#=>[top,right,bottom,left] [0.5, 1, 0.5, 2]
RGhost::Document.new :paper => :letter, :margin => [0, 0, 0, 0], :encoding => 'IsoLatin'  do |doc|


  doc.define_tags do
    tag :font1, :name => 'TimesBold', :size => 12, :color => '#000000'
    tag :font2, :name => 'Times', :size => 12, :color => '#000000'
    tag :font3, :name => 'Arial', :size => 4, :color => '#707070'
  end

  
  doc.shape_content :color => "#FFFFFF"
  doc.border :color => '#123456', :width => 2

  doc.moveto :x => 0.05, :y => 0
  doc.lineto :x => 0.05, :y => 27.94

  doc.moveto :x => 21.59, :y => 0
  doc.lineto :x => 21.59, :y => 27.94

  #######################

  h = 27.94
  c = 21.59

  he = 3.39
  ce = 10.16

  ms = 2.105
  ml = 0.4
  mc = 0.5

  mse = 1
  mle = 1
  esp_lin = 0.254 * 2

  lin = 0
  col = 0

  for p in @pessoas do

#    doc.polygon :x => ml + col * (mc + ce), :y => ms+((6-lin)*he) do
#      node :x => ce,  :y => 0
#      node :x => 0,  :y => he
#      node :x => -ce, :y => 0
#      node :x => 0,  :y => -he
#    end

    linha1 = p.nome
    linha2 = p.endereco
    linha3 = p.bairro + ' - ' + p.cidade + ' - ' + p.uf
    cep = p.cep.to_s.empty? ? '' :  p.cep[0,2] + '.' + p.cep[2,3] + '-' + p.cep[5,3]
    linha4 = cep
    linha5 = ''

    ##  Linha 1
    doc.moveto :x =>ml + (mle) + col * (mc + ce), :y => ms + he + ((6-lin)*he) - mse
    doc.show linha1, :align => :show_left, :tag => :font1

    ##  Linha 2
    doc.moveto :x =>ml + (mle) + col * (mc + ce), :y => ms + he + ((6-lin)*he) - mse - esp_lin
    doc.show linha2, :align => :show_left, :tag => :font2

    ##  Linha 3
    doc.moveto :x =>ml + (mle) + col * (mc + ce), :y => ms + he + ((6-lin)*he) - mse - 2 * esp_lin
    doc.show linha3, :align => :show_left, :tag => :font2

    ##  Linha 4
    doc.moveto :x =>ml + (mle) + col * (mc + ce), :y => ms + he + ((6-lin)*he) - mse - 3 * esp_lin
    doc.show linha4, :align => :show_left, :tag => :font2

    ##  Linha 5 - Info sobre parcela
    doc.moveto :x =>ml + (mle) + col * (mc + ce) + 0.87 * ce, :y => ms + he + ((6-lin)*he) - mse - 3.1 * esp_lin
    doc.show linha5, :align => :show_right, :tag => :font3


    if col == 0 then
      col = 1
    else
      lin = (lin == 6) ? 0 : lin + 1
      col = 0
    end
    
    if (lin == 0) and (col == 0)
      doc.next_page
    end

  end
end
