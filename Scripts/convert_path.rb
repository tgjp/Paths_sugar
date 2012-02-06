#!/usr/bin/env ruby
$KCODE = 'U'

require 'yaml'
require 'pp'

def to_rel(base_dir, target)
  sep = /#{File::SEPARATOR}+/o
  base_dir = base_dir.split(sep)
  target = target.split(sep)
  while base_dir.first == target.first
    base_dir.shift
    target.shift
  end
  File.join([".."]*base_dir.size+target)
end

#pp ENV

if (ENV['E_SUGARPATH'])
  config = YAML.load( File.open("#{ENV['E_SUGARPATH']}/Support/Config.yaml").read )
else
  config = YAML.load( File.open("/Users/tg/Dev_Sugar/Paths_sugar/Support/Config.yaml").read )
end

path = STDIN.read.strip

config['prosubs'].each do |i|
  path = path.sub(i[0], i[1]);
end

replacements = config['replacements']

if (ENV['E_DIRECTORY'])
  base_dir = ENV['E_DIRECTORY']
else
  base_dir = ''
end

re_protocol = /^(https?|ftps?)/i

replacements.each do |i|
  re = Regexp.new( i['regexp'], Regexp::IGNORECASE )
  
  if path =~ re
  	file_path = $1
  	file_ext = $2
        
    if i['type'] == 'image'
      
      pixelWidth = ''
      pixelHeight = ''
      if path !~ re_protocol
        IO.popen('sips -g pixelWidth -g pixelHeight ' << path) do |io|
          while io.gets
            if ($_ =~ /pixelWidth: ([0-9]+)$/)
              pixelWidth = $1
            end
            if ($_ =~ /pixelHeight: ([0-9]+)$/)
              pixelHeight = $1
            end
          end
        end
      end
      
		  if path !~ re_protocol
		    rel_path = to_rel( base_dir, file_path )
		  else
		    rel_path = path
		  end
		  
      print i['pattern'].gsub('{path}', rel_path ).gsub('{ext}', file_ext).gsub('{pixelWidth}', pixelWidth).gsub('{pixelHeight}', pixelHeight) 
      exit
    end
    
    if i['type'] == 'file'
      
			if path !~ re_protocol
			  rel_path = to_rel( base_dir, file_path )
			else
			  rel_path = path
			end
			
      print i['pattern'].gsub('{path}', rel_path ).gsub('{ext}', file_ext)
      exit
    end
  end
end
