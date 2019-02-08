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

def filename(node)
  ancestors = node.ancestors.reverse[4..10]
  (ancestors << node).collect{ |n| to_url(n["text"]) }.join("_")
end

def archetype(node)
  ancestors = node.ancestors.reverse[4..10]
  return "Menu" if ancestors.length < 1 && !node["_note"]
  ancestors[0]["text"]
end

def aspect(node)
  ancestors = node.ancestors.reverse[4..10]
  return if ancestors.length < 2
  ancestors[1]["text"]
end

def image(title)
end

def type(node,generalize=false)
  ancestors = node.ancestors.reverse[4..10]
  return "Menu" if ancestors.length < 1
  return "Aspect" if ["Mind","Body","Heart","Spirit"].include? node["text"]
  return "Archetype" if node["text"].include?("Mature") || node["text"].include?("Shadow")
  return "Sub Archetype" if ["Mind","Body","Heart","Spirit"].include?(ancestors[1]["text"]) && ancestors.length == 2
  return "Quality"
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

def generate_links(text, link_table, title)
  return unless text
  link_table.each do |link|
    next if title.include? link["title"]
    text = text.gsub(/\b(#{link["title"]}|#{link["title"].downcase})\b/,'[\1]' + "(#{link['link']})")
    # text = text.gsub(/\b(?:#{link["title"].downcase})\b/,"[#{link['title'].downcase}](#{link['link']})")
  end
  text
end

def generate (node, link_table)

  @title = node["text"]
  @description = generate_links(node["_note"], link_table, @title)
  @permalink = permalink(node)
  @archetype = archetype(node)
  @aspect = aspect(node)
  @type = type(node,false)
  @type_general = type(node,true)
  @draft = @description.nil? || (@description.include? "#draft")
  @draft = false if @type == "Aspect" || @type == "Menu"

  puts "Generating" + "    " + @title

  file_name = "#{$Directory}/#{filename(node)}.md"

  f = File.new(file_name, 'w')

  f.write("---\n")
  f.write("title: #{@title}\n")
  f.write("permalink: #{@permalink}\n")
  f.write("archetype: #{@archetype}\n") #king/lover/magician/warrior
  f.write("category: #{@archetype}\n") #king/lover/magician/warrior
  f.write("aspect: #{@aspect}\n") if @aspect #north/south/west/east
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

def link_table(doc)
  table = []
  @doc.css("outline").each do |node|

    @ancestors = node.ancestors.reverse[3..10]

    next unless @ancestors
    next unless @ancestors[0]
    next if node["text"].start_with?("_")

    if @ancestors.length > 1 && @ancestors[1]["text"].start_with?("_")
      puts "skipping #{node["text"]}"
    else
      @description = node["_note"]
      @title = node["text"]
      @permalink = permalink(node)
      @archetype = archetype(node)
      @aspect = aspect(node)
      @type = type(node,false)
      @type_general = type(node,true)
      @draft = @description.nil? || (@description.include? "#draft")
      @draft = false if @type == "Aspect" || @type == "Menu"

      table << {"link" => @permalink, "title" => @title.gsub("Shadow","").gsub("Mature","").strip} unless @type == "Aspect" || @type == "Menu"
    end



  end

  table
end

def generate_all
  @doc = Nokogiri::XML(File.open($SOURCE))
  # @doc.css("outline[_note]").each do |node|

  @link_table = link_table(@doc)

  puts @link_table.inspect


  @doc.css("outline").each do |node|

    @ancestors = node.ancestors.reverse[3..10]

    next unless @ancestors
    next unless @ancestors[0]
    next if node["text"].start_with?("_")

    if @ancestors.length > 1 && @ancestors[1]["text"].start_with?("_")
      puts "skipping #{node["text"]}"
    else
      generate(node, @link_table)
    end
  end
end

prepare_input
refresh_directory
generate_all
