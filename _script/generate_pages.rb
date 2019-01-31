require "Nokogiri"
require 'fileutils'


$Directory = "../generated"

def refresh_directory
  # Refreshing directory
  FileUtils.remove_dir($Directory)
  Dir.mkdir($Directory)
end


@doc = Nokogiri::XML(File.open("dynalist-2019-1-30.opml"))

def generate (node,ancestors)

  puts "Generating" + "    " + node["text"] + "  \t\t\t\t  " + @ancestors.collect{ |n| n["text"] }.join(":")

  file_name = "#{$Directory}/#{node["text"].gsub(" ","_")}.md"

  f = File.new(file_name, 'w')
  f.write("---")
  f.write("---")
  f.write(node["text"])
  f.write(node["_note"])
  f.close
end


def generate_all
  @doc.css("outline[_note]")[0..5].each do |node|

    @ancestors = node.ancestors.reverse[4..10]

    if @ancestors[0]["text"].start_with?("_")
      puts "skipping #{node["text"]}"
    else
      generate(node, @ancestors)
    end
  end
end

refresh_directory
generate_all
