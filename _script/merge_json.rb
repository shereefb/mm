require "Nokogiri"
require 'fileutils'
require 'json'


$GEO = "exported.geojson" #exported by geojson editor
$ARCH = "archetypes.json" #exported by generate_pages.rb
$OUT = "final.json"

$geo = nil
$arch = nil

def load_files
    file = File.read($GEO)
    $geo = JSON.parse(file)

    file = File.read($ARCH)
    $arch = JSON.parse(file)
end

def process_arch
    $arch.each do |archetype|
        replace_or_add(archetype)
    end
end


def replace_or_add(archetype)
    found = false

    #replace
    $geo['features'].each do |feature|
        if feature['properties']['title'].downcase == archetype['title'].downcase
            puts 'REPLACE ' + archetype['title']
            feature['properties'] = archetype
            found = true
        end
    end

    #add
    unless found
        puts 'NEW ' + archetype['title']
        newfeature = Hash['type' => 'Feature', 'properties' => archetype]
        newfeature["geometry"] = Hash[ 'type' => 'Point', 'coordinates' => [500,500] ]
        $geo['features'].push newfeature
    end
end

def overwrite_output
  f = File.new($OUT, 'w')
  f.write($geo.to_json)
  f.close
end

load_files
process_arch
overwrite_output