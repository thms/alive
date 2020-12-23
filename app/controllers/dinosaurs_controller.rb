require 'graphviz'

class DinosaursController < ApplicationController
  before_action :set_dinosaur, only: [:show, :edit, :update, :destroy]

  # GET /dinosaurs
  # GET /dinosaurs.json
  def index
    @dinosaurs = Dinosaur.where(nil)
    @dinosaurs = @dinosaurs.filter_by_rarity(params[:rarity]) if params[:rarity].present?
    @dinosaurs = @dinosaurs.order_by_dna(params[:dna]) if params[:dna].present?

    g = Graphviz::Graph.new
    # add all dinosaurs as unconnected nodes
    @dinosaurs.map {|dinosaur| add_node(g, dinosaur)}
    # connect each hybrid to its ingredients, need to load ingredients if filtering , missing second level when filtering
    @dinosaurs.each do |dinosaur|
      dinosaur_node = g.get_node(node_name(dinosaur)).first
      if dinosaur.left
        left_node = g.get_node(node_name(dinosaur.left)).first || add_node(g, dinosaur.left)
        dinosaur_node.connect(left_node)
        if dinosaur.left.left && params[:rarity].present?
          left_left_node = g.get_node(node_name(dinosaur.left.left)).first || add_node(g, dinosaur.left.left)
          left_node.connect(left_left_node)
        end
        if dinosaur.left.right && params[:rarity].present?
          left_right_node = g.get_node(node_name(dinosaur.left.right)).first || add_node(g, dinosaur.left.right)
          left_node.connect(left_right_node)
        end
      end
      if dinosaur.right
        right_node = g.get_node(node_name(dinosaur.right)).first || add_node(g, dinosaur.right)
        dinosaur_node.connect(right_node)
        if dinosaur.right.left && params[:rarity].present?
          right_left_node = g.get_node(node_name(dinosaur.right.left)).first || add_node(g, dinosaur.right.left)
          right_node.connect(right_left_node)
        end
        if dinosaur.right.right && params[:rarity].present?
          right_right_node = g.get_node(node_name(dinosaur.right.right)).first || add_node(g, dinosaur.right.right)
          right_node.connect(right_right_node)
        end
      end
    end
    @graph = Graphviz::output(g, format: 'svg')
  end

  # GET /dinosaurs/1
  # GET /dinosaurs/1.json
  def show
    g = Graphviz::Graph.new
    me = add_node(g, @dinosaur, 'box')
    node_add_children(g, me, @dinosaur)
    node_add_hybrids(g, me, @dinosaur)
    purge_edges!(g)
    @graph = Graphviz::output(g, format: 'svg')
    @next_level = @dinosaur.level > 0 ? @dinosaur.level + 1 : Constants::STARTING_LEVELS[@dinosaur.rarity.to_sym]
    @cost = @dinosaur.cost_to_level(@next_level)
  end

  # GET /dinosaurs/new
  def new
    @dinosaur = Dinosaur.new
  end

  # GET /dinosaurs/1/edit
  def edit
  end

  # POST /dinosaurs
  # POST /dinosaurs.json
  def create
    @dinosaur = Dinosaur.new(dinosaur_params)

    respond_to do |format|
      if @dinosaur.save
        format.html { redirect_to @dinosaur, notice: 'Dinosaur was successfully created.' }
        format.json { render :show, status: :created, location: @dinosaur }
      else
        format.html { render :new }
        format.json { render json: @dinosaur.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dinosaurs/1
  # PATCH/PUT /dinosaurs/1.json
  def update
    respond_to do |format|
      if @dinosaur.update(dinosaur_params)
        format.html { redirect_to @dinosaur, notice: 'Dinosaur was successfully updated.' }
        format.json { render :show, status: :ok, location: @dinosaur }
      else
        format.html { render :edit }
        format.json { render json: @dinosaur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dinosaurs/1
  # DELETE /dinosaurs/1.json
  def destroy
    @dinosaur.destroy
    respond_to do |format|
      format.html { redirect_to dinosaurs_url, notice: 'Dinosaur was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dinosaur
      @dinosaur = Dinosaur.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dinosaur_params
      params.require(:dinosaur).permit(:name, :level, :rarity, :health, :speed, :damage, :dna, :is_hybrid, :left_id, :right_id)
    end

    #COLORS = {common: 'grey', rare: 'blue', epic: 'orange', legendary: 'red', unique: 'green'}

    # add and format a single node if not already on the graph
    # if already on the graph returns the existing node
    # connects if already on the graph and not yet connected
    def add_node(parent, dinosaur, shape='oval')
      node = parent.add_node(node_name(dinosaur))
      node.attributes[:id] = dinosaur.id
      node.attributes[:color] = Constants::COLORS[dinosaur.rarity.to_sym]
      node.attributes[:shape] = shape
      node.attributes[:URL] = "/dinosaurs/" + dinosaur.id.to_s
      node
    end

    # add recursivly all possible Hybrids, and recurse upwards
    # TODO: add all components of the hybrids downwards too.
    def node_add_hybrids(graph, node, dinosaur)
      dinosaur.possible_hybrids.each do |hybrid|
        hybrid_node = add_node(graph, hybrid)
        hybrid_node.connect(node)
        # add children of hybrid, unless already connected (cases: only one child is already in the graph and connected)
        node_add_children(graph, hybrid_node, hybrid)
        node_add_hybrids(graph, hybrid_node, hybrid)
      end
    end

    # add recursivley all children
    # possible cases: child is already in the graph and connected - do nothing
    # child is in the graph, and not connected
    def node_add_children(graph, node, dinosaur)
      if dinosaur.left
        left_node = add_node(node, dinosaur.left)
        left_node.connections.uniq!
        node_add_children(graph, left_node, dinosaur.left)
      end
      if dinosaur.right
        right_node = add_node(node, dinosaur.right)
        right_node.connections.uniq!
        node_add_children(graph, right_node, dinosaur.right)
      end

    end

    def node_name(dinosaur)
      "#{dinosaur.name}\n#{dinosaur.level}"
    end

    # remove duplicate edges
    def purge_edges!(graph)
      graph.edges.uniq!
    end
end
