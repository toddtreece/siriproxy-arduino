require 'cora'
require 'siri_objects'
require 'json' 
require 'open-uri'
require 'httparty'

class SiriProxy::Plugin::Arduino < SiriProxy::Plugin

  attr_accessor :host

  def initialize(config = {})
    self.host = config["host"]
  end

  listen_for /(cable|tv|system) power/i do |device|

    say "Attempting to send the power command." 

    Thread.new {
      
      begin
        t = TCPSocket.new("#{self.host}", 8000)
      rescue
        say "Shit broke."
      else
        t.print "{power,#{device.downcase}}"
        say "Sent motherfucking power command."
        t.close
      end

      request_completed 

    }

  end


  listen_for /source to (cable|netflix|apple)/i do |source|

    say "Attempting to change source to #{source.downcase}." 

    Thread.new {

      begin
        t = TCPSocket.new("#{self.host}", 8000)
      rescue
        say "Shit broke."
      else
        t.print "{source,#{source.downcase}}"
        say "Source changed."
        t.close
      end

      request_completed 

    }

  end

  listen_for /number ([0-9,]*[0-9])/i do |number|
    
    say "Changing channel to: #{number}"

    Thread.new {

      begin
        t = TCPSocket.new("#{self.host}", 8000)
      rescue
        say "Shit broke."
      else
        t.print "{channel,#{number}}"
        say "I changed the channel for your lazy ass."
        t.close
      end

      request_completed 

    }
     
  end

end
