# coding: utf-8

class ReportsController < ApplicationController

  # GET /teste
  # GET /teste.xml
  # GET /teste.pdf
  def teste
    @pessoas = Pessoa.order("nome")

    respond_to do |format|
      format.html  
      format.xml    { render :xml => @pessoas }
      format.pdf    { rghost_render :pdf, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
      format.jpg    { rghost_render :jpg, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
      format.png    { rghost_render :png, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
    end

  end



  def etiquetas

    data = "'2011-01-05'"

    sql = <<sql
        select distinct p.*
        from pessoas p
        join compradors c
        on p.id = c.pessoa_id
        join vendas v
        on v.id = c.venda_id
        and v.lote_id in
        (
        select distinct
        l.id
        from boletos b
        join promissorias p
        on b.promissoria_id = p.id
        join vendas v
        on v.id = p.venda_id
        join lotes l
        on l.id = v.lote_id
        WHERE b.data_emissao = #{data}
        order by l.id
        )
        order by p.nome
sql

    puts sql


    @pessoas = Pessoa.find_by_sql sql
    @boletos = {}

    @pessoas.each do |pessoa|

      sql = "select distinct" + \
        " a.nome," + \
        " l.numero," + \
        " p.num," + \
        " p.num_total," + \
        " p.cod_tipo_parcela" + \
        " from boletos b" + \
        " join promissorias p" + \
        " on b.promissoria_id = p.id" + \
        " join vendas v" + \
        " on v.id = p.venda_id" + \
        " join lotes l" + \
        " on l.id = v.lote_id" + \
        " join areas a" + \
        " on l.area_id = a.id" + \
        " join compradors c" + \
        " on c.venda_id = v.id" + \
        " where b.data_emissao = #{data}" + \
        " and c.pessoa_id = #{pessoa.id}" + \
        " order by a.nome, l.numero, p.cod_tipo_parcela, p.num"

      @boletos_da_pessoa = Pessoa.find_by_sql sql

      texto = ""
      nome_lote = nome_lote_ant = ""
      tipo_parcela = tipo_parcela_ant = 0
      parcela_atual = parcela_anterior = 0
      num_total = num_total_ant = 0
      num_parcelas_tipo = 0
      flag_ultima_parcela_consecutiva = false

      @boletos_da_pessoa.each do |d|

        parcela_atual = d.num.to_i
        num_total = d.num_total
        nome_lote = "#{d.nome}-#{d.numero}-"

        if nome_lote != nome_lote_ant then
          ##
          ## Novo lote
          ##
          if texto.empty? then
            texto << "#{nome_lote}#{d.num}"
          else
            if num_parcelas_tipo == 1 then
              texto << "/#{num_total_ant}, #{nome_lote}#{d.num}"
            else
              termo = flag_ultima_parcela_consecutiva ? "_" : ","
              texto << "#{termo}#{parcela_anterior}/#{num_total_ant}, #{nome_lote}#{d.num}"
            end
          end
          num_parcelas_tipo = 1

        else
          ##
          ## Mesmo lote
          ##
          if tipo_parcela != tipo_parcela_ant then
            ##
            ## Novo tipo de parcela
            ##
            texto << "#fim_lote#, #{nome_lote}#{d.num}"
            num_parcelas_tipo = 1
          else
            ##
            ## Mesmo tipo de parcela
            ##
            if (parcela_atual - parcela_anterior) == 1 then
              ##
              ## Parcela consecutiva
              ##
              texto << ""
              flag_ultima_parcela_consecutiva = true
              num_parcelas_tipo += 1
            else
              ##
              ##  Parcela NÃO consecutiva
              ##
              texto << "_#{parcela_anterior},#{parcela_atual}"
              flag_ultima_parcela_consecutiva = false
              num_parcelas_tipo += 1
            end

          end
        end

        nome_lote_ant = nome_lote
        tipo_parcela_ant = tipo_parcela
        parcela_anterior = parcela_atual
        num_total_ant = num_total

      end
      
      if num_parcelas_tipo == 1 then
        texto << "/#{num_total_ant}"
      else
        termo = flag_ultima_parcela_consecutiva ? "_" : ","
        texto << "#{termo}#{parcela_anterior}/#{num_total_ant}"
      end


      @boletos[pessoa.id] = texto
    end

    respond_to do |format|
      format.html
      format.xml    { render :xml => @pessoas }
      format.pdf    { rghost_render :pdf, :report => {:action => 'etiquetas'}, :filename => 'etiquetas.pdf', :disposition => "inline" }
      format.jpg    { rghost_render :jpg, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
      format.png    { rghost_render :png, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
    end
  end






  def etiquetas_iptu

#    sql = <<sql_type
#    SELECT DISTINCT
#    	pessoas.nome,
#    	pessoas.endereco,
#    	pessoas.bairro,
#    	pessoas.cidade,
#    	pessoas.uf,
#    	pessoas.cep
# 			--l.id
#    FROM lotes l INNER JOIN vendas v ON v.lote_id = l.id
#    	 INNER JOIN compradors ON v.id = compradors.venda_id
#    	 INNER JOIN pessoas ON pessoas.id = compradors.pessoa_id
# 			 INNER JOIN promissorias p ON p.venda_id = v.id
# 		   INNER JOIN boletos b ON b.promissoria_id = p.id
#    WHERE l.id IN
#    (192,224,227,219,206)
#    ORDER BY pessoas.nome
# sql_type

#     sql = <<sql_type
#     SELECT DISTINCT
#     pessoas.nome,
#         pessoas.endereco,
#         pessoas.bairro,
#         pessoas.cidade,
#         pessoas.uf,
#         pessoas.cep
#     FROM lotes l INNER JOIN vendas v ON v.lote_id = l.id
#     INNER JOIN compradors ON v.id = compradors.venda_id
#     INNER JOIN pessoas ON pessoas.id = compradors.pessoa_id
#     INNER JOIN promissorias p ON p.venda_id = v.id
#     INNER JOIN boletos b ON b.promissoria_id = p.id AND b.data_emissao = '2014-07-14'
#     WHERE pessoas.id NOT IN ()
#     ORDER BY pessoas.nome
# sql_type

    sql = <<sql_type
    SELECT DISTINCT
    pessoas.nome,
        pessoas.endereco,
        pessoas.bairro,
        pessoas.cidade,
        pessoas.uf,
        pessoas.cep
    FROM pessoas
    WHERE pessoas.id IN (670,679,645,706)
    ORDER BY pessoas.nome
sql_type

    @pessoas = Pessoa.find_by_sql sql

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

      #doc.render :pdf, :filename => '.\\public\\etiquetas_iptu.pdf'
      doc.render :pdf, :filename => 'C:\\Caixa\\titulos\\etiquetas.pdf'
    end
  end



  def espelho
    @lotes = Lote.order("id")

    respond_to do |format|
      format.html
      format.xml    { render :xml => @lotes }
      format.pdf    { rghost_render :pdf, :report => {:action => 'espelho'}, :filename => 'espelho.pdf', :disposition => "inline" }
      format.jpg    { rghost_render :jpg, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
      format.png    { rghost_render :png, :report => {:action => 'teste'}, :filename => 'pessoas.pdf', :disposition => "inline" }
    end
  end



  def extrato
    @lote = Lote.find(params[:id])

    respond_to do |format|
      format.html
      format.xml    { render :xml => @lote }
      format.pdf    { rghost_render :pdf, :report => {:action => 'extrato'}, :filename => 'extrato.pdf', :disposition => "inline" }
      format.jpg    { rghost_render :jpg, :report => {:action => 'extrato'}, :filename => 'extrato.jpg', :disposition => "inline" }
      format.png    { rghost_render :png, :report => {:action => 'extrato'}, :filename => 'extrato.png', :disposition => "inline" }
    end

  end


  def gnucash
    @d = Biblioteca.get_extrato_gnucash
  end

  def gnucash2

    arq_db = "C:\\Dropbox\\Hansa Fly\\Contabilidade\\GnuCash\\Hansafly.sqlite.gnucash"
    #arq_db = "C:\\Onedrive\\Hansa Fly\\Contabilidade\\GnuCash\\Hansafly.sqlite.gnucash"
    db = SQLite3::Database.new(arq_db)

    sql = <<sql_type
    SELECT
        (substr(t.post_date, 7, 2) || '/' || substr(t.post_date, 5, 2) || '/' || substr(t.post_date, 1, 4)) as data,
        a3.name || ':' || a2.name || ':' || a.name || ':' || t.description AS descricao,
        s.value_num / 100.0 AS debito,
        s.value_num / 100.0 AS credito
    FROM
    splits s
    JOIN transactions t ON t.guid = s.tx_guid
    JOIN accounts a ON a.guid = s.account_guid
    JOIN accounts a2 ON a.parent_guid = a2.guid
    LEFT JOIN accounts a3 ON a2.parent_guid = a3.guid
    WHERE
    s.account_guid <> '9067050731851f1b7e01ec713a4c5712'
    AND s.tx_guid IN (
                         SELECT
                            t.guid
                         FROM
                            splits s
                         JOIN transactions t ON t.guid = s.tx_guid
                         WHERE
                            s.account_guid = '9067050731851f1b7e01ec713a4c5712'
    )
    ORDER BY
    t.post_date
sql_type



    @l = []
    rs = db.execute(sql)
    saldo = 0
    agora = DateTime.now.strftime("%Y-%m-%d").to_date

    rs.each do |linha|
      r = []
      credito = linha[2] < 0 ? -linha[2] : 0
      debito = linha[2] > 0 ? linha[2] : 0
      saldo += credito - debito
      data = Biblioteca::data2date(linha[0])

      if (agora - data) <= 75 then
        puts "#{linha[0]}: #{linha[1]}"
        puts "  debito:  #{debito}"
        puts "  credito: #{credito}"
        puts "  saldo: #{saldo}"
        puts "################"

        r << linha[0]
        r << linha[1]
        r << credito
        r << debito
        r << saldo

        @l << r
      end
    end

    respond_to do |format|
      format.html
      #format.csv { send_data @products.to_csv }
      format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end


  end




  def pagamentos_por_area
    area = 30

    @dados = {}
    lotes = {}
    titulos = []
    linhas = []
    titulos << 'Lote'
    titulos << 'Superfície'
    titulos << 'Valor pago'
    titulos << 'Saldo devedor'

    sql = <<sql_type
    SELECT
    numero,
    superficie
    FROM lotes l
    WHERE l.area_id = #{area}
    ORDER BY numero
sql_type

    rs = Lote.find_by_sql sql
    rs.each do |l|
      lote = {}
      lote[:superficie] = l.superficie.to_i
      lotes[l.numero.to_i] = lote
    end

    sql = <<sql_type
    SELECT
    l.numero as lote,
    SUM(p.valor_pago) as valor_pago
    FROM pagamentos p
    JOIN boletos b ON b.id = p.boleto_id
    JOIN promissorias pm ON pm.id = b.promissoria_id
    JOIN vendas v ON v.id = pm.venda_id AND v.cod_status IN (51,52,65,53)
    JOIN lotes l ON l.id = v.lote_id
    JOIN areas a ON a.id = l.area_id and a.id = #{area}
    GROUP BY
    l.numero
    ORDER BY 1
sql_type

    sum_valor_pago = 0
    rs = Pagamento.find_by_sql sql
    rs.each do |l|
      lote = lotes[l.lote.to_i]
      lote[:valor_pago] = l.valor_pago.to_f
      sum_valor_pago += l.valor_pago.to_f
    end

    sql = <<sql_type
    SELECT
    p.id,
    l.numero as lote,
    p.valor_original as valor_parcela
    FROM promissorias p
    JOIN vendas v ON v.id = p.venda_id AND v.cod_status IN (51,52,65,53)
    JOIN lotes l ON l.id = v.lote_id
    JOIN areas a ON a.id = l.area_id and a.id = #{area}
		WHERE p.cod_status IN (1,20,26)
    ORDER BY lote
sql_type

    sum_saldo_devedor = 0
    rs = Promissoria.find_by_sql sql
    rs.each do |p|
      pm = Promissoria.find(p.id)
      dados = pm.get_valores (Time.now)

      lote = lotes[p.lote]

      valor_parcela = (dados[:valor_mora]).to_f
      lote[:saldo_devedor] = lote.include?(:saldo_devedor) ? lote[:saldo_devedor] + valor_parcela : valor_parcela
      sum_saldo_devedor += valor_parcela
    end

    colunas = []
    colunas << ''
    colunas << ''
    colunas << sum_valor_pago.to_currency(Currency::BRL)
    colunas << sum_saldo_devedor.to_currency(Currency::BRL)
    linhas << colunas

    lotes.sort_by { |key, value| key.to_i }.each { |key, value|
      colunas = []
      colunas << key
      colunas << value[:superficie]
      colunas << ((value.include?(:valor_pago)) ? (value[:valor_pago]).to_currency(Currency::BRL) : "")
      colunas << ((value.include?(:saldo_devedor)) ? (value[:saldo_devedor]).to_currency(Currency::BRL) : "")
      linhas << colunas
    }

    @dados[:titulos] = titulos
    @dados[:linhas] = linhas
  end




  def creditos_receber

    meses = {}

#     sql = <<sql_type
# SELECT
# *
# FROM promissorias p
# WHERE cod_status IN (1,26)
# ORDER BY data_vencimento
# sql_type

    sql = <<sql_type
SELECT
p.*,
l.area_id
FROM promissorias p
JOIN vendas v
ON v.id = p.venda_id
JOIN lotes l
ON l.id = v.lote_id
WHERE p.cod_status IN (1,26)
ORDER BY p.data_vencimento
sql_type


    # rs = Promissoria.find_by_sql sql
    # rs.each do |p|
    #   puts "#{p.data_vencimento} - #{p.venda.lote.area.id}"
    # end

    rs = Promissoria.find_by_sql sql
    rs.each do |p|
      pm = Promissoria.find(p.id)
      v = pm.get_valores Time.now
      valor = v[:valor_mora].nil? ? 0 : v[:valor_mora]
      mes = "#{p.data_vencimento.year}-#{p.data_vencimento.month}"

      if meses.has_key?(mes) then
        #meses[mes][p.area_id] = meses[mes][p.area_id] + valor
        area = (meses[mes])
        area[p.area_id] =+ valor
      else
        area = {}
        area[p.area_id] = valor
        meses[mes] = area
      end

      puts "#{p.area_id} - #{p.data_vencimento} - #{Biblioteca::format_currency(valor)} - #{mes}"

    end




  end


end
