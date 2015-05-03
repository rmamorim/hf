


#=>[top,right,bottom,left]
RGhost::Document.new :paper => :letter, :margin => [0.5, 1, 0.5, 2], :encoding => 'IsoLatin'  do |doc|


  doc.border :color => '#AAFAA9'

  doc.define_tags do
    tag :font1, :name => 'Helvetica', :size => 10, :color => '#F34811'
    tag :font2, :name => 'Times',     :size => 14, :color => '#A4297A'
    tag :font3, :name => 'TimesBold', :size => 12, :color => '#AA3903'
  end



  doc.moveto :x => 0.05, :y => 0
  doc.lineto :x => 0.05, :y => 27.94

  doc.moveto :x => 21.59, :y => 0
  doc.lineto :x => 21.59, :y => 27.94

  #margem superior/inferior = 2.105
  #margem esquerda/direta = 0.423333

  h = 27.94
  c = 21.59

  he = 3.39
  ce = 10.16

  ms = 2.105
  ml = 0.4233333

  mse = 1
  mle = 1
  esp_lin = 0.254 * 2
  

  doc.moveto :x => 0, :y => 0
  doc.lineto :x => 10, :y => 10

  doc.polygon :x => ml, :y => ms do
    node :x => c - 2 * ml,  :y => 0
    node :x => 0,  :y => h - 2 * ms
    node :x => -(c - 2 * ml), :y => 0
    node :x => 0,  :y => -(h - 2 * ms)
  end

  for i in (1..7) do

    doc.polygon :x => ml, :y => ms+((i-1)*he) do
      node :x => ce,  :y => 0
      node :x => 0,  :y => he
      node :x => -ce, :y => 0
      node :x => 0,  :y => -he
    end

    #doc.rmoveto :x => 0, :y => - esp
    #doc.moveto :x =>ml + (ce / 2), :y => he + ms +((i-1)*he) - esp
    #doc.show "Ricardo de Miranda Amorim", :align => :show_center


    ##  Linha 1
    doc.moveto :x =>ml + (mle), :y => ms + he + ((i-1)*he) - mse
    doc.show "Ricardo de Miranda Amorim", :align => :show_left, :tag => :font3

    ##  Linha 2
    doc.moveto :x =>ml + (mle), :y => ms + he + ((i-1)*he) - mse - esp_lin
    doc.show "Rua Nascimento Silva, 121/102 - Ipanema", :align => :show_left

    ##  Linha 3
    doc.moveto :x =>ml + (mle), :y => ms + he + ((i-1)*he) - mse - 2 * esp_lin
    doc.show "Rio de Janeiro - RJ", :align => :show_left

    ##  Linha 4
    doc.moveto :x =>ml + (mle), :y => ms + he + ((i-1)*he) - mse - 3 * esp_lin
    doc.show "22.421-020", :align => :show_left, :tag => :font2



    doc.polygon :x => ml + ce + ml, :y => ms+((i-1)*he) do
      node :x => ce,  :y => 0
      node :x => 0,  :y => he
      node :x => -ce, :y => 0
      node :x => 0,  :y => -he
    end


#    my_text="<font3>Ricardo de Miranda Amorim<br/>Rua Nascimento Silva, 121/102 - Ipanema<br/>Rio de Janeiro - RJ<br/>22.421-020</font3>"
#    doc.text_area my_text,\
#      :x => (ce + ml) + ml + (ce / 2),\
#      :y => he + ms +((i-1)*he) - 4 * esp,\
#      :width => 6,\
#      :text_align => :left,\
#      :row_height => 0.45 ,\
#      :tag_parse => true


  end


  #  doc.grid :data => @pessoas do |g|
  #    g.column :nome, :align => :left
  #    g.column :cpf
  #  end
end
