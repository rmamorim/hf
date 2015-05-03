


#=>[top,right,bottom,left]
RGhost::Document.new :paper => :letter, :margin => [0.5, 1, 0.5, 2], :encoding => 'IsoLatin'  do |doc|


  doc.border :color => '#AAFAA9'

  doc.define_tags do
    tag :font1, :name => 'TimesBold', :size => 12, :color => '#000000'
    tag :font2, :name => 'Times', :size => 12, :color => '#000000'
  end



  h = 27.94
  c = 21.59

  he = 3.39
  ce = 10.16

  ms = 2.105
  ml = 0.4233333

  mse = 1
  mle = 1
  esp_lin = 0.254 * 2

  i = 1
  for p in @pessoas do

    doc.polygon :x => ml, :y => ms+((7-i)*he) do
      node :x => ce,  :y => 0
      node :x => 0,  :y => he
      node :x => -ce, :y => 0
      node :x => 0,  :y => -he
    end

    linha1 = p.nome
    linha2 = p.endereco
    linha3 = p.bairro + ' - ' + p.cidade + ' - ' + p.uf
    linha4 = p.cep

    ##  Linha 1
    doc.moveto :x =>ml + (mle), :y => ms + he + ((7-i)*he) - mse
    doc.show linha1, :align => :show_left, :tag => :font1

    ##  Linha 2
    doc.moveto :x =>ml + (mle), :y => ms + he + ((7-i)*he) - mse - esp_lin
    doc.show linha2, :align => :show_left, :tag => :font2

    ##  Linha 3
    doc.moveto :x =>ml + (mle), :y => ms + he + ((7-i)*he) - mse - 2 * esp_lin
    doc.show linha3, :align => :show_left, :tag => :font2

    ##  Linha 4
    doc.moveto :x =>ml + (mle), :y => ms + he + ((7-i)*he) - mse - 3 * esp_lin
    doc.show linha4, :align => :show_left, :tag => :font2



    doc.polygon :x => ml + ce + ml, :y => ms+((7-i)*he) do
      node :x => ce,  :y => 0
      node :x => 0,  :y => he
      node :x => -ce, :y => 0
      node :x => 0,  :y => -he
    end

    i = (i == 7) ? 1 : i + 1

    if i == 1
      break
    end

  end
end
