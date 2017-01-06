#!/usr/bin/env ruby
require 'pp'
require 'rsync'
require 'shellwords'
require 'open3'
require 'fileutils'
require 'find'

$stdout = File.open("/root/ruby_scripts/rsync.log", "a")
$stderr = File.open("/root/ruby_scripts/rsync_error.log","a")


def cleanup(folder)
		FileUtils.rm_rf(folder)
end

if Dir.glob('/root/Downloads/**').empty?
	puts "nothing to do"
else 

	Dir.glob('/root/Downloads/**').each do |folder|
		files_in_dir = []
		Dir.chdir(folder)
  	Find.find('.') do |path| 
      files_in_dir << File.extname(path)
  	end
  files_in_dir = files_in_dir.reject!{|file| file.empty?}
		if files_in_dir.any? {|filename| filename == '.part'}
    	puts "#{folder} still downloading"
		elsif
			files_in_dir.count == 1 && files_in_dir[0] == '.lock'
			puts "Only File left is lockfile cleaning it up"	
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
			cmd = "rsync -avr --remove-source-files --exclude 'rsync.lock' --progress  /root/Downloads/#{@folder} xxxxxx@xxxxx:/home/xxx/Movies"
			Open3.popen3(cmd) do |stdin, stdout, stderr|
			  puts stdout.read
			end
		end
	end
end

