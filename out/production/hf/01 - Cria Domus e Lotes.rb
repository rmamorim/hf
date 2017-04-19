



a = Area.new
a.nome = "DUS"
a.save


domus = Area.find_by_nome("DUS")

##
## Quadra A
##
(1..14).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "A"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra B
##
(1..30).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "B"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra C
##
(1..33).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "C"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra D
##
(1..16).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "D"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra E
##
(1..20).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "E"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra F
##
(1..27).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "F"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra G
##
(1..24).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "G"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end

##
## Quadra H
##
(1..26).each do |f|
  l = Lote.new
  l.area_id = domus.id
  l.quadra = "H"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.save
end


