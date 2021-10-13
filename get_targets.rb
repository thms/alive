require 'json'
files = Dir.glob(File.join('tmp', 'dinosaurs', '*.json'))
files.each do |name|
  file = File.read(name)
  creature =  JSON.parse(file)['pageProps']['detail']
  creature['moves'].each do |move|
    move['effects'].each do |effect|
    puts effect['target']
    end
  end
  creature['moves_counter'].each do |move|
    move['effects'].each do |effect|
    puts effect['target']
    end
  end
  creature['moves_swap_in'].each do |move|
    move['effects'].each do |effect|
    puts effect['target']
    end
  end
  creature['moves_on_escape'].each do |move|
    move['effects'].each do |effect|
    puts effect['target']
    end
  end
end
