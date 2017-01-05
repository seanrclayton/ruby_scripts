#!/usr/bin/env ruby
require 'pp'
require 'rsync'
require 'shellwords'
require 'open3'
require 'fileutils'

$stdout = File.open("/root/ruby_scripts/rsync.log", "a")
$stderr = File.open("/root/ruby_scripts/rsync_error.log","a")


def cleanup(folder)
	if Dir.glob("#{folder}/*").empty?
		FileUtils.rm_rf(folder)
	else
		puts "there seems to still be some stuff in the folders"
	end
end

if Dir.glob('/root/Downloads/**').empty?
	puts "nothing to do"
else 

	Dir.glob('/root/Downloads/**').each do |folder|
		Dir.chdir(folder)
    if Dir.glob("**").any?{|filename| File.extname(filename) == '.part'}
			puts ""
			puts "#{File.basename(folder)} still downloading..."
		elsif
			Dir.glob("**").length == 1 && File.basename(Dir.glob("#{folder}/*")[0]) == 'rsync.lock'
			puts "Only File left is lockfile cleaning it up"	
			File.delete("#{folder}/rsync.lock")
			puts "Cleaning up Directory #{folder}"
			cleanup(folder)
		elsif Dir.glob("**").any?{|filename| File.basename(filename) == 'rsync.lock'}
			puts "found lock file waiting for rsync to finish"			
		else 
			puts ""
			puts "#{File.basename(folder)} is done.."
			puts Dir.glob("**")
			puts "locking rsync"
			File.open("#{folder}/rsync.lock", 'w') {|f| f.write(Time.now)}
			@folder = Shellwords.escape("#{File.basename(folder)}")
			cmd = "rsync -avr --remove-source-files --exclude 'rsync.lock' --progress  /root/Downloads/#{@folder} xxxxx@xxxxx:/home/clayton/Movies"
			Open3.popen3(cmd) do |stdin, stdout, stderr|
			  puts stdout.read
			end
		end
	end
end

