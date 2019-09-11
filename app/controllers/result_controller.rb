class ResultController < ApplicationController
    def product
        @city = params[:location]
        loc = ''
        val = Geocoder.search(@city)
        if val[0] != nil
            loc = val.first.city + ',' + val.first.country
            loc = loc.downcase
            if val.first.country.downcase == "chile" and val.first.city.downcase == "santiago"
                loc = "santiago,cl"
            end
        else
            flash[:failure] = "City or country not found"
            redirect_to controller: 'home', action: 'home'
        end
        #history es con suscripcion pagada
        @las = val.first.city
        weatherjson = 'http://api.openweathermap.org/data/2.5/weather?q=' + loc  + '&appid=b4344374965e420e9ad7109ad84b7f00'
        weat = HTTParty.get(weatherjson)
        @weather = JSON.parse(weat.body)#conseguir la temperatura promedio
        # check = JSON.parse(weat.headers.inspect)

        # if check["cod"] == "404"
        #     flash[:failure] = "City or country not found"
        #     redirect_to controller: 'home', action: 'home'
        # end
        @w = @weather["weather"]
        @dayg = @w[0]["main"]#tiempo
        @day = @w[0]["description"]#descripcion tiempo
        @temp1 = @weather["main"] #
        @temp = @temp1["temp"].to_i - 273 #temperatura

        @opcion = 0 #sumar 7 para siguiente producto
        if params[:card].to_i
            @opcion = params[:card].to_i
            if @opcion == 5
                @opcion = 0
            end
        end 
        require 'openssl'
        require 'open-uri'
        urls = ''
        if @temp < 5
            urls = "https://www.dafiti.cl/femenino/vestuario/parkas/"
        elsif @temp >= 5 and @temp < 18
            urls = "https://www.dafiti.cl/femenino/trench/"
        elsif @temp >= 18 and @temp < 23
            urls = "https://www.dafiti.cl/femenino/vestuario/chalecos-y-sweaters/"
        elsif @temp > 23
            urls = "https://www.dafiti.cl/femenino/vestuario/blusas/"
        end
        doc = Nokogiri::HTML(open(urls, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
        entries = doc.css('.productsCatalog')
        i = 0
        ra = []
        while i < 5
            be = entries.css('li')[i*7]
            ra.push(be)
            i = i + 1
        end
        ra.each do |r|
            r.search('.itm-product-addcard-box').each do |s|
                s.remove
            end
            r.search('.itm-price-installments').each do |s|
                s.remove
            end
            r.search('.itm-priceBox').each do |s|
                s.remove
            end
            r.search('.itm-free-shipping').each do |s|
                s.remove
            end
            r.search('.itm-saleFlagPercent').each do |s|
                s.remove
            end
        end
        @rate = ra[@opcion]
    end
    
end
