require "Nokogiri"
require 'fileutils'


$Directory = "../_cards"
$SOURCE = "processed.OPML"
$RAW = "dynalist-2019-1-31.opml"

def prepare_input
  raw = File.open($RAW, "r")
  processed = File.new($SOURCE, "w")
  raw.each_line do |line|
    processed.write line.gsub("##","&#10;##").gsub("&#10","  &#10")
  end

  raw.close
  processed.close
end

def refresh_directory
  # Refreshing directory
  FileUtils.remove_dir($Directory)
  Dir.mkdir($Directory)
end

def to_url(string)
  string.downcase.gsub(" ","_")
end

def permalink(ancestors,title)
  "/" + ancestors.collect{ |n| to_url(n["text"]) }.join("/") + "/#{to_url(title)}"
end

def archetype(ancestors)
  ancestors[0]["text"]
end

def direction(ancestors)
    ancestors[2]["text"] if ancestors[1]["text"] == "Direction"
end

def image(title)
end

def type(ancestors,title)
  if ancestors[1]["text"] == "Direction"
    ancestors[3]["text"]
  else
    ancestors[2]["text"]
  end
end


def generate (node,ancestors)

  @title = node["text"]
  @description = node["_note"]
  @permalink = permalink(ancestors,@title)
  @archetype = archetype(ancestors)
  @direction = direction(ancestors)
  @type = type(ancestors,@title)

  puts "Generating" + "    " + @title + "  \t\t\t\t  " + ancestors.collect{ |n| n["text"] }.join(":")

  file_name = "#{$Directory}/#{to_url(@title)}.md"

  f = File.new(file_name, 'w')

  f.write("---\n")
  f.write("layout: page\n")
  f.write("title: #{@title}\n")
  f.write("permalink: #{@permalink}\n")
  f.write("archetype: #{@archetype}\n") #king/lover/magician/warrior
  f.write("direction: #{@direction}\n") if @direction #north/south/west/east
  f.write("type: #{@type}\n") #quality/skill/mature/shadow
  f.write("image: /images/back/#{to_url@title}.jpg\n")
  f.write("---\n")
  # f.write("##{@title}\n")
  f.write("#{@description}\n")
  f.close
end


def generate_all
  @doc = Nokogiri::XML(File.open($SOURCE))
  @doc.css("outline[_note]").each do |node|

    @ancestors = node.ancestors.reverse[4..10]

    if @ancestors[0]["text"].start_with?("_")
      puts "skipping #{node["text"]}"
    else
      generate(node, @ancestors)
    end
  end
end

prepare_input
refresh_directory
generate_all