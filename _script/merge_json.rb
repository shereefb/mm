require "Nokogiri"
require 'fileutils'
require 'json'


$GEO = "exported.geojson" #exported by geojson editor
$ARCH = "archetypes.json" #exported by generate_pages.rb

$geo = nil
$arch = nil

def load_files
    file = File.open($GEO)
    $geo = JSON.parse(file.read)

    file = File.open($ARCH)
    $arch = JSON.parse(arch.read, :quirks_mode => true)
end

def process_arch
    $arch.each do |archetype|
        replace_or_add(archetype)
    end
end


def replace_or_add(archetype)
    $geo['features'].each do |feature|
        if feature['properties']['name'] == archetype.title
            break
        end
    end

end

def overwrite_output()
end

load_files
process_arch
overwrite_output