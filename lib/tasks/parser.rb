require 'nokogiri'
require 'open-uri'
require 'mechanize'

def parse_method
  link = "http://www.eldorado.com.ua/phones-and-communications/c1038944/"
  puts "Parsing '#{link}'"

  doc = Nokogiri::HTML(open(link))
  doc.css('div.menu-categories-i').each do |item|
    unless Phone.find_by(title: item.at_css('a').css('span').text)
      Phone.create(title: item.at_css('a').css('span').text)
      puts "created Phone: #{item.at_css('a').css('span').text}"
    end

    max_page = -1
    page_items = Nokogiri::HTML(open(item.at_css('a')['href']))
    page_items.css('.page-i').each do |page|
      max_page = page.text
    end

    if max_page.to_i > 0

    else
      page_items.css('.g-i-title a').each do |item_phone|
        puts item_phone['href']
      end
    end




  end


end