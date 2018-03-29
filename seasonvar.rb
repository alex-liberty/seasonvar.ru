require 'open-uri'
require 'json'
require 'curb'
require 'nokogiri'
require 'csv'

#http://seasonvar.ru/serial-16402-CHernyj_spisok-5-sezon.html 16
#http://seasonvar.ru/serial-16756-Anatomiya_strasti--14-sezon.html 16
#http://seasonvar.ru/serial-16313-Lyutcifer--03-sezon.html 18
#curl 'http://seasonvar.ru/player.php' -H ''  --data ''

class SeasonVar
  
  def initialize
  end

  def request(url, player: false)
    curl = Curl::Easy::new
    curl.url = url
    
    if player
      curl.post_body = "id=16313&serial=7297&type=html5&secure=faa7fafc58c85aec20d915eafa9756ef&time=1521823433"
      curl.headers = {"x-requested-with" => "XMLHttpRequest"}
    end
    
    curl.perform
    curl.body_str
  end

  def get_params(url)
    doc = Nokogiri::HTML(request(url))
    player = doc.xpath("//script[contains(text(), 'data4play')]").text
    serial = doc.xpath("//div[@data-id-season]")
    params = {
      :mark => player[/'secureMark': '(\w+)',/, 1],
      :time => player[/'time': (\d+)/, 1],
      :season => serial.xpath("./@data-id-season").text,
      :serial => serial.xpath("./@data-id-serial").text
    }
    
    params
  end

  def get_playlist(params)
    
  end

  def get_default_playlist(serial)
    params = get_params(serial)
    listUrl = "http://seasonvar.ru/playls2/#{params[:mark]}/trans/#{params[:season]}/plist.txt?time=#{params[:time]}"
    list = JSON(request(listUrl))
    list.each{|item| puts "#{item['title'].gsub('<br>', '')}: #{item['file']}" }
  end

  def get_current_list(file)
    list = CSV.read(file)
  end

  def set_current_list(file, list)
    CSV.open(file, 'wb') { |csv| list.each{|row| csv << row}}
  end
end
url = "http://seasonvar.ru/serial-2739-Stal_noj_alhimik.html"
file = "serials.txt"

puts get_current_list(file).inspect


