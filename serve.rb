require 'rubygems'
require 'mechanize'
require 'logger'
require 'sinatra' 
 
  class ApartmentSearch
 
    def self.url(until_price=2300,from_square_meter=70,until_square_meter=95,until_rooms=4,from_rooms=3,until_floor=3) "http://www.yad2.co.il/Nadlan/rent.php?AreaID=22&SubAreaID=0&HomeTypeID=&fromRooms=#{from_rooms}&untilRooms=#{until_rooms}&FromFloor=&Floor=#{until_floor}&fromSquareMeter=#{from_square_meter}&untilSquareMeter=#{until_square_meter}&fromPrice=&untilPrice=#{until_price}&PriceType=1&fromSquareMeter=#{from_square_meter}&untilSquareMeter=#{until_square_meter}&Furniture=1&Parking=1&AirConditioner=1&FreeText=&ad_sr=1"
    end
     
    @@all_apartments = [] 
    
    def self.all_apartments
      @@all_apartments
    end
     
    def initialize
       @agent = WWW::Mechanize.new { |a| a.log = Logger.new('apartment.log') }
    end
    attr_reader :agent
    
    def load_apartments        
        page = agent.get(ApartmentSearch.url)
        trs = page.search('//div[@id="main_table"]//tr[@class="ActiveLink"]')
        trs.each do |tr| 
          cells = tr / "td"
          
          address = cells[8]
          price = cells[10]
          room_count = cells[12]
          entry_date = cells[14]
          floor = cells[16]
          link = "http://www.yad2.co.il/Nadlan/" + ((cells[24]/"a")[1]/"@href").to_s   
          # posted_on = (cells/"font").inner_html
          a = Apartment.new(address,price,room_count,entry_date,floor,link) 
          
          @@all_apartments << a
          
        end
        
        rescue => e
        puts "an error (#{e}) occured on #{ApartmentSearch.url}"
    end
    
  end
    
  class Apartment
  
    attr_accessor :address, :price,:room_count,:entry_date,:floor,:link #,:posted_on

=begin    
    def parse_time_string(text)
       if (cells/"font").inner_html.match(/^(\d\d)\/(\d\d)\/(\d\d\d\d)$/) # 05/08/2009
         Time.parse("#{$2,$1,$3}}") # israel vs US month/day thing. (2,1,3)
       else
         @agent.log.warn "Put Time.now, could not parse out yad2 td/font date."
         Time.now
       end
    end
=end
        
    def initialize(address,price,room_count,entry_date,floor,link)
      @address,@price,@room_count,@entry_date,@floor,@link,@posted_on = address,price,room_count,entry_date,floor,link
    end
    
  end 
      

get "/" do
  "try /yad2 , or /yad2.rss "
end

get "/yad2" do
  ApartmentSearch.new.load_apartments
  @apartments = ApartmentSearch.all_apartments
  haml :list
end

get "/yad2.rss" do
  ApartmentSearch.new.load_apartments
  @apartments = ApartmentSearch.all_apartments
  header 'Content-Type' => 'text/xml; charset=windows-1255'
  builder :rss
end

