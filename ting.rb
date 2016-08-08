#!/usr/bin/env ruby
 
require 'httparty'
require 'pp'
require 'nokogiri'
require 'mail'
 
options = { :address    => "smtp.gmail.com",
  :port                 => 587,
  :user_name            => 'seancvolusion',
  :password             => '*******',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }
                                      
Mail.defaults do
  delivery_method :smtp, options
end
 
 
ip = ""
im_bad = []
log_file = Dir.home + "/ip.txt"
 
res = Nokogiri::HTML(HTTParty.get('http://www.whatsmyip.net/', :headers => {"Protocol" => "Http/1.1", "Connection" => "keep-alive", "Keep-Alive" => "1000", "User-Agent" => "Web-Agent"}  ))
 
 
 
res.css('header')[0].css('input').to_a.flatten.each do |x|
  if x.to_s =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
    im_bad << x.to_s.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/).to_s
  end
end
 
if im_bad.count > 1
  ip = "Some shit happened man, we got more than we expected. Heres what i got #{im_bad}"
elsif im_bad.count == 0
  ip = "I gots not ip returned.. shit"
elsif im_bad.count == 1 
  ip = im_bad[0]
end
 
if File.exist?(log_file)
  ip_in_file = File.open(log_file).read.gsub(/\s/,'')
  if ip != ip_in_file
    File.new(log_file, 'w').puts(ip)  
    Mail.deliver do
         to 'sean.r.clayton@gmail.com'
       from 'seancvolusion@gmail.com'
    subject 'Public IP changed'
       body ip
    end
    print ip
  end  
else 
  ip_in_file = File.new(log_file, 'w')
  ip_in_file.puts(ip)
  print ip
end
