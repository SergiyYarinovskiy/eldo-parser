require 'nokogiri'
require 'open-uri'
require 'mechanize'

def parse_method

  link = "http://www.eldorado.com.ua/phones-and-communications/c1038944/"
  puts "Parsing '#{link}'"

  doc = Nokogiri::HTML(open(link))

  puts 'Working on phones and communication...'

  doc.css('div.menu-categories-i').each do |item|

    phone = Phone.find_by(title: item.at_css('a').css('span').text)

    if phone.nil?
      phone = Phone.create(title: item.at_css('a').css('span').text)
      puts "created Phone: #{item.at_css('a').css('span').text}"
    end

    page_items = Nokogiri::HTML(open(item.at_css('a')['href']))

    if page_items.css('div.menu-categories-i').empty?
      parse_page_with_category(page_items, phone, item)
    else
      page_items.css('div.menu-categories-i').each do |category_inside|
        parse_page_with_category(Nokogiri::HTML(open(category_inside.at_css('a')['href'])), phone, item)
      end
    end

  end

  puts 'Parsing had ended successfully'

end

def parse_page_with_category(page_items, phone, item)

  max_page = -1

  page_items.css('.page-i').each do |page|
    max_page = page.text
  end

  if max_page.to_i > 0
    (1..max_page.to_i).each do |page|
      parse_page_with_items(Nokogiri::HTML(open("#{item.at_css('a')['href']}page=#{page}/")), phone)
    end
  else
    parse_page_with_items(page_items, phone)
  end

end

def attach_imgs(item_main, item_phone_db)

  all_images = []
  if item_main.at_css('div figure a')['href']
    all_images << item_main.at_css('div figure a')['href']
  else
    all_images << item_main.at_css('div figure a img').attributes['src'].value
  end

  item_main.css('li.pp-image-preview-item a').each { |preview| all_images << preview['href'] }

  all_images.each do |img_url|
    image = Mechanize.new.get(img_url)

    unless Photo.find_by(photo_img_file_name: image.filename)
      image.save("public/tmp/#{image.filename}")
      Photo.create(photo_img: File.open("public/tmp/#{image.filename}", 'rb'), item_phone: item_phone_db)
      File.delete("public/tmp/#{image.filename}")
    end
  end

end

def parse_page_with_items(page_items, phone)

  page_items.css('.g-tile-item').each do |item_phone|

    if item_phone.at_css('.g-i-price-buy')

      item_main = Nokogiri::HTML(open(item_phone.at_css('.g-i-title a')['href']))

      item_phone_db = ItemPhone.find_by(code: item_main.at_css('.pp-code').text.strip.delete("Код товара\n							"))

      if item_phone_db
        item_phone_db.update(name: item_main.at_css('h1').text,\
              description: item_main.at_css('.description').text,\
              price: item_main.at_css('.bg-red-ie-left-white-large span').text.delete(' ').to_f)
      else
        item_phone_db = ItemPhone.create(code: item_main.at_css('.pp-code').text.strip.delete("Код товара\n							"),\
              name: item_main.at_css('h1').text, description: item_main.at_css('.description').text,\
              price: item_main.at_css('.bg-red-ie-left-white-large span').text.delete(' ').to_f, phone: phone)
        puts "created ItemPhone: #{item_main.at_css('h1').text}"
      end

      attach_imgs(item_main, item_phone_db)

      unless item_main.css("li[name='characteristics'] a").empty?

        group = ''

        puts item_main.at_css('h1').text
        Nokogiri::HTML(open(item_main.css("li[name='characteristics'] a").first['href'])).at_css('table.pp-characteristics-table').css('tr').each do |characteristic|

          if characteristic.at_css('th.pp-characteristics-title')

            group = characteristic.at_css('th.pp-characteristics-title').text
            next

          else

            next if characteristic.at_css('td.p-page-specific-separate')
            if Attribute.find_by(group_name: group, item_phone: item_phone_db, name: characteristic.at_css('div.bb-name').text)
              Attribute.find_by(group_name: group, item_phone: item_phone_db,\
                    name: characteristic.at_css('div.bb-name').text).update(value: characteristic.at_css('td').text)
            else
              Attribute.create(group_name: group, item_phone: item_phone_db,\
                  name: characteristic.at_css('div.bb-name').text, value: characteristic.at_css('td').text)
            end

          end

        end

      end

    end

  end

end