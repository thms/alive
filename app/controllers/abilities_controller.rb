class AbilitiesController < ApplicationController
  helper_method :sort_column, :sort_direction

  # GET /abilities
  # GET /abilities.json
  def index
    class_names = Dir.glob(File.join(Rails.root, "app", 'abilities', '*')).collect{|path| File.basename(path, '.rb').camelize}
    class_names.delete('Ability')
    class_names.delete('Modifiers')
    class_names.delete('Minions')
    class_names.delete('Bosses')
    @abilities = class_names.map{|class_name| {name: class_name, is_implemented: class_name.constantize.is_implemented}}
    @abilities.sort_by! {|ability| ability[sort_column.to_sym]}
    @abilities.reverse! if sort_direction == 'desc'
  end

  # GET /abilities/{ClassName}.json
  def show
    class_name = params[:id].gsub('-','_').classify
    @ability = class_name.constantize.new
  end

  private
  def sort_column
    ['name', 'is_implemented'].include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
