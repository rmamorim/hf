require 'rubygems'
require 'rghost'

#RGhost::Config::GS[:path]= “C:\\gs\\bin\\gswin32c.exe”
#RGhost::Config::GS[:path]= "C:\\Program Files (x86)\\gs\\gs9.05\\bin\\gswin32c.exe"
#RGhost::Config.is_ok?.render :pdf, :filename => "C:\\Torrents\\mytest.pdf"


=begin
RGhost::Document.new :paper => :A4 do |doc|
 doc.show "Hi this is my RGhost Report"
 doc.next_row
 doc.grid :data => @clients do |g|
   g.column :name, :title => "Client name", :align => :center
   g.column :site, :title => "Site url"
   g.column :created_at, :title => "Client since", :format => lambda{|d| d.strftime('%d/%m/%Y')}
 end
end

=end




=begin
 doc=RGhost::Document.new
 doc.show 'Hello World' , :color => :blue
 doc.render :pdf, :filename => 'C:\\Torrents\\mytest2.pdf'
=end


RGhost::Document.new :paper => :A4 do |doc|
  doc.show 'Hello World' , :color => :blue
  doc.next_row
  doc.show "Hi this is my RGhost Report"
  doc.next_row
=begin
  doc.grid :data => @clients do |g|
     g.column :name, :title => "Client name", :align => :center
     g.column :site, :title => "Site url"
     g.column :created_at, :title => "Client since", :format => lambda{|d| d.strftime('%d/%m/%Y')}
  end
=end
  doc.render :pdf, :filename => 'C:\\Torrents\\mytest2.pdf'
end