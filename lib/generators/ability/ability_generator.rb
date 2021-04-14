class AbilityGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_ability_file
    template "ability.erb", "app/abilities/#{file_name}.rb" unless File.exist?("app/abilities/#{file_name}.rb")
  end

end
