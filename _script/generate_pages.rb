require "Nokogiri"
require 'fileutils'


$Directory = "../_cards"
$SOURCE = "processed.OPML"
$RAW = "dynalist-2019-2-7.opml"

def prepare_input
  raw = File.open($RAW, "r")
  processed = File.new($SOURCE, "w")
  raw.each_line do |line|
    processed.write line.gsub("##","&#10;##").gsub("&#10","  &#10").gsub("#printed","").gsub("###","|")
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

def permalink(node)
  ancestors = node.ancestors.reverse[4..10]
  "/" + ancestors.collect{ |n| to_url(n["text"]) }.join("/") + "/#{to_url(node["text"])}"
end

def archetype(ancestors)
  ancestors[0]["text"]
end

def direction(ancestors)
  return if ancestors.length < 3
    ancestors[2]["text"] if ancestors[1]["text"] != "Archetype"
end

def image(title)
end

def type(ancestors,generalize=false)
  return "Menu" if ancestors.length < 3
  return "Archetype" if ancestors[1]["text"] == "Archetype"
  generalize ? ancestors[1]["text"] : ancestors[2]["text"]
end

def menu(node,depth)
  out = ""
  space = "  " * depth
  if node.children
    node.children.each  do |child|
      if child["text"]
        out += space + "- [#{child["text"]}](#{permalink(child)})\n"
        out += menu(child, depth + 1) if child.children
     end
    end
  end
  out
end

def generate (node,ancestors)

  @description = node["_note"]
  @title = node["text"]
  @draft = @description.nil? || (@description.include? "#draft")
  @permalink = permalink(node)
  @archetype = archetype(ancestors)
  @direction = direction(ancestors)
  @type = type(ancestors,false)
  @type_general = type(ancestors,true)

  puts "Generating" + "    " + @title + "  \t\t\t\t  " + ancestors.collect{ |n| n["text"] }.join(":")

  file_name = "#{$Directory}/#{to_url(@title)}.md"

  f = File.new(file_name, 'w')

  f.write("---\n")
  f.write("title: #{@title}\n")
  f.write("permalink: #{@permalink}\n")
  f.write("archetype: #{@archetype}\n") #king/lover/magician/warrior
  f.write("category: #{@archetype}\n") #king/lover/magician/warrior
  f.write("direction: #{@direction}\n") if @direction #north/south/west/east
  f.write("type: #{@type}\n") #quality/skill/mature/shadow
  f.write("type_general: #{@type_general}\n") #quality/skill/archetype
  f.write("image: /images/back/#{to_url@title}.jpg\n")
  f.write("draft: #{@draft}\n")

  if @type_general == "Archetype"
    f.write("toc: true\n")
    f.write("toc_label: Quick Jump\n")
  end

  f.write("---\n")
  # f.write("##{@title}\n")
  f.write("#{@description}\n")
  f.write("---\n")
  f.write(menu(node,0))
  f.close
end


def generate_all
  @doc = Nokogiri::XML(File.open($SOURCE))
  # @doc.css("outline[_note]").each do |node|
  @doc.css("outline[text]").each do |node|

    @ancestors = node.ancestors.reverse[4..10]

    next unless @ancestors
    next unless @ancestors[0]

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
