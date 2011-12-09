require 'cora'
require 'siri_objects'
require 'json'
require 'open-uri'
require 'httparty'
require 'json'
require "scrapi"

class SiriProxy::Plugin::Arduino < SiriProxy::Plugin

  attr_accessor :host
  attr_accessor :port
  attr_accessor :listings_url
  attr_accessor :channels
  attr_accessor :image_prefix
  attr_accessor :episode_prefix
  attr_accessor :custom_channels

  def initialize(config = {})
    
    self.host = config["host"]
    self.port = config["port"]
    self.listings_url = config["listings_url"]
    self.image_prefix = config["image_prefix"]
    self.custom_channels = config["custom_channels"]

    channel_item = Scraper.define do
  
      process "div.grid-img", :id => "@data-src"  
      process "span.grid-network", :name => :text
      process "span.grid-channel", :channel => :text
      
      result :id, :name, :channel

    end

    listings = Scraper.define do

      array :channels
      process "div.grid-source", :channels=>channel_item

      result :channels

    end

    self.channels = listings.scrape(URI.parse(self.listings_url))

  end

  def change_channel(number)

    say "I'm changing the channel to: #{number}"

    Thread.new {

      begin
        t = TCPSocket.new("#{self.host}", self.port)
      rescue
        say "Something broke."
      else
        t.print "{channel,#{number}}"
        say "I changed the channel for you."
        t.close
      end

      request_completed 

    }

  end

  def show_info(number)

    say "Let me check."
    
    Thread.new {
      
      t = Time.new

      #set the time to the current half hour block
      current_time = Time.local(t.year, t.month, t.day, t.hour, t.min/30*30).getutc

      channel = self.channels.select { |e| e[:channel].to_i.to_s == number }

      channel_id = channel[0][:id]

      searching = true

      attempts = 0
      
      #loop until a valid program is found
      while searching do

        #die if we've tried too many times
        if attempts == 10
          say "Sorry, but I couldn't find anything."
          request_completed

          return
        end
        
        url = self.episode_prefix + channel_id + '_' + current_time.strftime("%Y-%m-%d_%HX%M")

        page = HTTParty.get(url).body rescue nil

        show_info = JSON.parse(page)

        if show['title'].nil?
          #didn't find info playing about the current show
          #so go back a half hour until
          #we find valid info from the start of the show
          current_time = current_time - (30 * 60)
          attempts += 1
        else
          searching = false
        end

      end

      say "Here is what's playing:"

      object = SiriAddViews.new
      
      object.make_root(last_ref_id)

      answer_content = Array.new(
        SiriAnswerLine.new('logo', self.image_prefix + channel_id + '.png'),
        SiriAnswerLine.new(show['title'])
      )

      answer_content << SiriAnswerLine.new(show['programDescription']) unless show['programDescription'].nil?

      answer = SiriAnswer.new(channel[0][:name], answer_content)

      object.views << SiriAnswerSnippet.new([answer])
      
      send_object object

      response = ask "Would you like to watch #{show['title']}"

      if(response =~ /yes/i)
        change_channel number
      else
        say "Good Choice."
      end
      
      request_completed 

    }

  end

  #Example: "Siri, can you turn the TV power on?"
  listen_for /(cable|tv|system) power/i do |device|

    say "One moment."

    Thread.new {
      
      begin
        t = TCPSocket.new("#{self.host}", self.port)
      rescue
        say "Something broke."
      else
        t.print "{power,#{device.downcase}}"
        say "Sent power command to the #{device}."
        t.close
      end

      request_completed 

    }

  end

  #Example: "Siri, can you change the TV source to Netflix?"
  listen_for /source to (cable|netflix|apple)/i do |source|

    say "Attempting to change source to #{source.downcase}." 

    Thread.new {

      begin
        t = TCPSocket.new("#{self.host}", self.port)
      rescue
        say "Something broke."
      else
        t.print "{source,#{source.downcase}}"
        say "Source changed."
        t.close
      end

      request_completed 

    }

  end

  #Example: "Siri, what's on channel 25?"
  listen_for /on channel ([0-9,]*[0-9])/i do |number|
    
    show_info number
    
  end

  #Example: "Siri, what's on CNN?"
  listen_for /on (#{self.custom_channels.join('|')})/i do |name|
    
    show_info self.custom_channels[name.downcase]
    
  end

  #Example: "Siri, can you change the channel to CNN?"
  listen_for /channel to (#{self.custom_channels.join('|')})/i do |name|
    
    change_channel self.custom_channels[name.downcase]
    
  end

  #Example: "Siri, can you change channel to number 25?"
  listen_for /number ([0-9,]*[0-9])/i do |number|
    
    change_channel number
     
  end
  
end
