




cotia = Area.find_by_nome("COT")

##
## Quadra B1
##
(1..6).each do |f|
  l = Lote.new
  l.area_id = cotia.id
  l.quadra = "B1"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.superficie = 466.83 if f == 1
  l.superficie = 375 if f == 2
  l.superficie = 375 if f == 3
  l.superficie = 375 if f == 4
  l.superficie = 375 if f == 5
  l.superficie = 461.51 if f == 6

  l.save
end

##
## Quadra B2
##
(1..11).each do |f|
  l = Lote.new
  l.area_id = cotia.id
  l.quadra = "B2"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.superficie = 384.55 if f == 1
  l.superficie = 360 if f == 2
  l.superficie = 360 if f == 3
  l.superficie = 360 if f == 4
  l.superficie = 360 if f == 5
  l.superficie = 405.87 if f == 6
  l.superficie = 459.70 if f == 7
  l.superficie = 390 if f == 8
  l.superficie = 390 if f == 9
  l.superficie = 390 if f == 10
  l.superficie = 469.01 if f == 11

  l.save
end

##
## Quadra B3
##
(1..34).each do |f|
  l = Lote.new
  l.area_id = cotia.id
  l.quadra = "B3"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.superficie = 400.42 if f == 1
  l.superficie = 451.69 if f == 2
  l.superficie = 395.33 if f == 3
  l.superficie = 381.22 if f == 4
  l.superficie = 371.30 if f == 5
  l.superficie = 363.38 if f == 6
  l.superficie = 363.38 if f == 7
  l.superficie = 363.38 if f == 8
  l.superficie = 363.38 if f == 9
  l.superficie = 363.38 if f == 10
  l.superficie = 363.38 if f == 11
  l.superficie = 363.38 if f == 12
  l.superficie = 363.38 if f == 13
  l.superficie = 363.38 if f == 14
  l.superficie = 363.38 if f == 15
  l.superficie = 371.41 if f == 16
  l.superficie = 496.06 if f == 17
  l.superficie = 363.38 if f == 18
  l.superficie = 363.38 if f == 19
  l.superficie = 363.38 if f == 20
  l.superficie = 363.38 if f == 21
  l.superficie = 363.38 if f == 22
  l.superficie = 363.38 if f == 23
  l.superficie = 363.38 if f == 24
  l.superficie = 363.38 if f == 25
  l.superficie = 363.38 if f == 26
  l.superficie = 363.38 if f == 27
  l.superficie = 363.38 if f == 28
  l.superficie = 363.38 if f == 29
  l.superficie = 436.51 if f == 30
  l.superficie = 381.93 if f == 31
  l.superficie = 375 if f == 32
  l.superficie = 375 if f == 33
  l.superficie = 375 if f == 34




  l.save
end

##
## Quadra B4
##
(1..14).each do |f|
  l = Lote.new
  l.area_id = cotia.id
  l.quadra = "B4"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.superficie = 371.57 if f == 1
  l.superficie = 360.00 if f == 2
  l.superficie = 360.00 if f == 3
  l.superficie = 360.00 if f == 4
  l.superficie = 360.00 if f == 5
  l.superficie = 360.00 if f == 6
  l.superficie = 360.00 if f == 7
  l.superficie = 360.00 if f == 8
  l.superficie = 360.00 if f == 9
  l.superficie = 360.00 if f == 10
  l.superficie = 360.00 if f == 11
  l.superficie = 360.00 if f == 12
  l.superficie = 360.00 if f == 13
  l.superficie = 367.00 if f == 14

  l.save
end

##
## Quadra B5
##
(1..15).each do |f|
  l = Lote.new
  l.area_id = cotia.id
  l.quadra = "B5"
  l.numero = f.to_i
  l.cod_vendedor_access=1
  l.cod_status_access=4
  l.superficie = 371.50 if f == 1
  l.superficie = 360.00 if f == 2
  l.superficie = 360.00 if f == 3
  l.superficie = 360.00 if f == 4
  l.superficie = 360.00 if f == 5
  l.superficie = 360.00 if f == 6
  l.superficie = 360.00 if f == 7
  l.superficie = 360.00 if f == 8
  l.superficie = 360.00 if f == 9
  l.superficie = 360.00 if f == 10
  l.superficie = 360.00 if f == 11
  l.superficie = 360.00 if f == 12
  l.superficie = 360.00 if f == 13
  l.superficie = 360.00 if f == 14
  l.superficie = 371.57 if f == 15

  l.save
end


