require "Nokogiri"
require 'fileutils'

FileUtils.remove_dir("../generated")

@doc = Nokogiri::XML(File.open("dynalist-2019-1-30.opml"))



@doc.css("outline[_note]").each do |node|

  @ancestors = node.ancestors.reverse[4..10]

  if @ancestors[0]["text"].start_with?("_")
    puts "skipping #{node["text"]}"
    next
  end

  puts "Generating" + "    " + node["text"] + "  \t\t\t\t  " + @ancestors.collect{ |n| n["text"] }.join(":")



end
