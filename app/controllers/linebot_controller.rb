class LinebotController < ApplicationController
  require 'line/bot'

  require 'open-uri'
  require 'json'

  protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
  #  unless client.validate_signature(body, signature)
  #    error 400 do 'Bad Request' end
  #  end
    events = client.parse_events_from(body)

    array = {}
    message = {}
    cond = []
    acckey= "6afcd32694c4130f6a1ce4a7dc21a98b"
    format= "json"
    hit_per_page = "10"
    uri   = "https://api.gnavi.co.jp/RestSearchAPI/20171214/?keyid=#{acckey}&format=#{format}&hit_per_page=#{hit_per_page}"
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
        ##ぐるナビAPI叩いて返す
	freeword = event.message['text']
	#prefname = event.message['text']
	p 'line からのパラメタ = ' + event.message['text'] 
	#range = open(url)
        File.open("test.txt", "r") do |f|
            cond = JSON.parse(f.read)
#            p cond
            cond["freeword"] = freeword
        end

        cond_str = ''
        cond.each do |key, value|
           p key
           p value
           cond_str = cond_str + "&#{key}=#{value}"
        end
	#url  = sprintf("%s%s%s%s%s%s%s%s%s", uri, "?format=", format, "&keyid=", acckey, "&freeword=", freeword, "&lunch=", "1")
        url = uri + cond_str
	url = URI.encode url
	p url
	json = open(url)
	#array = {}
	json.each do |j|
	    array = JSON.parse(j)
	end

	msg = ''
        columns = [];
	array["rest"].each do |rest|
	     #puts rest["name"]
	     msg = msg + rest["name"] 
	     message = { 'type' => 'text', 'text' => rest["name"] }
	    #response = client.push_message("Ub8c67cfce315de9e3f841e7a2136f5a8", message)
	     #puts response
             columns.push({
                 "thumbnailImageUrl": rest["image_url"]["shop_image1"],
                 "title": rest["name"],
                 "text": rest["tel"],
                 "actions": [
                 {
                     "type": "uri",
                     "label": "電話する",
                     "uri": "tel://" + rest["tel"]
		 },
                 {
                     "type": "uri",
                     "label": "お店のページへ",
                     "uri": rest["url"]
                 }]
             });
            #message = {
            #type: 'text',
            #text: event.message['text']
            #}
	end
    File.open("test.txt", "r+") do |f|
	json_str = JSON.pretty_generate(cond)
	f.puts json_str
    end


message = [
  {
    "type": "template",
    "altText": "this is a carousel template",
    "template": {
        "type": "carousel",
        "columns": columns
	}
  },
#  {
#    "type": "text",
#    "text": "hogehoge"
#  }
       {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "ランチ営業も含みますか？",
                "actions": [
                     {
                       "type": "postback",
                        "label": "Yes",
                        "data": "1"
                      },
                      {
                        "type": "postback",
                        "label": "No",
                        "data": "0"
                      }
                ]
             }
        }
]


          #message = {
            #type: 'text',
            #text: event.message['text']
           #}
        end
      end

      #p array
      result = client.reply_message(event['replyToken'], message)
      p result
    end

    head :ok
  end



  private

# LINE Developers登録完了後に作成される環境変数の認証
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = "16d4b46218956a056db3c4f4347c8b89"
      config.channel_token = "iHPVoh0hjJevhBJNDV70+ls/K88LAlLmEHifF11gu0ppGsM8QI3r+y3+T/cxzxJOEYRhCLwKTC1a835s6tYFcW6xLcHllGo1Bexsz1ApUrP7RiupYqa+iEqhxyVEp+50K7z6afAVkFdOHzBCbPiqngdB04t89/1O/w1cDnyilFU="
    }
  end
end
