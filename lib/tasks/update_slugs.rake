namespace :dinosaurs do
  desc "Update slug"
  task :update_slug => :environment do
    Dinosaur.all.each do |dinosaur|
      dinosaur.update_attribute(:slug, dinosaur.name.parameterize)
    end
  end
end
