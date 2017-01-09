#!/usr/bin/env ruby

require 'pp'
require 'find'
require 'fileutils'

directory = "/home/clayton/TV/#{ARGV[0]}"
files_in_dir = []
@hash = {}
def make_plex_readable(directory)
	
	Dir.glob("#{directory}/**") do |path|
		unless FileTest.directory?(path)
			if path =~ /[a-zA-Z]{3}/
				folder = directory
				if folder.match(/\d+/).to_s.empty?
					season = 1
				else
					season = folder.match(/\d+/).to_s
				end
				#pp "#{File.basename(path).scan(/\d+/)}"
				@hash["#{folder}/#{File.basename(path)}"] = "#{folder}/#{ARGV[0]} - s#{season}e#{File.basename(path).scan(/\d+/)[0]}#{File.extname(path)}"
			#pp @hash
			elsif ! File.basename(path).match(/\d{4}/)
				puts "in elsif"
				@hash["#{folder}/#{File.basename(path)}"] = "#{folder}/#{File.basename(path).prepend('0').insert(2,'e').insert(0,'s')}"	
			else
				"puts in else"
				path = File.basename(path)
				@hash["#{folder}/#{File.basename(path)}"] = "#{folder}/#{File.basename(path).insert(2,'e').insert(0,'s')}"
			end
		end
	end
end

if File.directory?(directory)
	Dir.glob("#{directory}/**").each do |folder|
		if File.directory?(folder)
				Dir.chdir(folder)
				make_plex_readable(Dir.pwd)
		else
				make_plex_readable(directory)
		end
	
	end
else
	puts "#{directory} does not exist" 
end

@hash.each do |k,v|
#puts k 
#puts v 	
#pp File.exists?(k)
FileUtils.mv(k, v)
end

#./Episode - 18.mp4 
