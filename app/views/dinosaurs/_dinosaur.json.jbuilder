json.extract! dinosaur, :id, :name, :level, :rarity, :health, :damage, :armor, :critical_chance, :speed, :dna, :left_id, :right_id, :created_at, :updated_at
json.url dinosaur_url(dinosaur, format: :json)
