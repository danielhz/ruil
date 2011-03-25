require 'rubygems'
require 'mongo'

require 'ruil/resource'

module Ruil

  # {Ruil::MongoResource} objects get a CRUD interface to resources stored in
  # colletions of a Mongo database.
  #
  #    db = Mongo::Connection.new.db('mydb')
  #    resource = Ruil::MongoResource.new(db, 'mycollection')
  #
  # You could generate a CRUD for all the collections in a database.
  #
  #    db.collection_names.each do |collection_name|
  #      Ruil::MongoResource.new(db, 'mycollection')
  #    end
  #
  # You could access to initialized resources using the {Ruil::MongoResource.[]}
  # method.
  #
  #    resource = Ruil::MongoResource[:my_collection_name]
  class MongoResource

    @@resources = {}

    # The items per page when listing resources.
    # @return [Fixnum] the items per page
    attr_accessor :page_size

    # A procedure to map items when listing resources.
    # @return [Proc] a mapping when listing resources
    attr_accessor :map_list_item

    # A procedure to map a resource to show.
    # @return [Proc] a mapping when showing resources.
    attr_accessor :map_show_item

    # The directory where templates are.
    # @return [String] the templates directory
    attr_accessor :templates_dir

    # The actions associated with the mongo resource.
    # This attribute allows you to redefine the behavior of actions
    # for any {Ruil::MongoResource}.
    # @return [Hash<Symbol><Ruil::MongoResource] the actions.
    attr_accessor :actions

    # Creates a new {Ruil::MongoResource}.
    #
    # @param [Mongo::DB] db
    #   the resource database
    #
    # @param [String] collection_name
    #   the name of the collection that stores the resources
    def initialize(db, collection_name)
      @db              = db
      @collection_name = collection_name
      @collection      = @db[@collection_name]
      @page_size       = 10
      @map_list_item   = Proc.new { |item| item }
      @map_show_item   = Proc.new { |item| item }
      @templates_dir   = File.join("dynamic", "templates")
      @actions         = {}
      @@resources[@collection_name.to_sym] = self
      yield self if block_given?
      # Procedure to load resource templates
      @load_templates  = Proc.new do |resource, action|
        Dir[File.join(@templates_dir, @collection_name, "#{action}.*.*.*")].each do |t|
          if /\.(html|xhtml)$/ === t
            resource << Ruil::Template.new(t)
          end
        end
      end
      # List resources
      @actions[:list] = Ruil::Resource.new("GET", "/#{@collection_name}/list") do |r|
        r.content_generator = Proc.new do |e|
          e[:page] = ( e[:request].params['page'] || 0 )
          items = @collection.find().skip(e[:page]).limit(@page_size)
          { :items => items.map { |item| @map_list_item.call(item) } }
        end
        @load_templates.call r, 'list'
      end
      # Show a resource
      @actions[:show] = Ruil::Resource.new("GET", "/#{@collection_name}/:_id") do |r|
        r.content_generator = Proc.new do |e|
          id = BSON::ObjectId.from_string(e[:path_info_params][:_id])
          item = @collection.find(:_id => id).first
          { :item => @map_show_item.call(item) }
        end
        @load_templates.call r, 'show'
      end
      # Create a new resource
      @actions[:post] = Ruil::Resource.new("POST", "/#{@collection_name}") do |r|
        # TODO
      end
      # Update a resource
      @actions[:put] = Ruil::Resource.new("PUT", "/#{@collection_name}/:_id") do |r|
        # TODO
      end
      # Delete a resource
      @actions[:delete] = Ruil::Resource.new("DELETE", "/#{@collection_name}/:_id") do |r|
        # TODO'
      end
    end

    # Get the resource names.
    #
    # @return [Array<Symbol>] the resource names.
    def self.resource_names
      @@resources.keys
    end

    # Get the resource for a collection.
    #
    # @param [Symbo] collection_name
    #   the collection name
    #
    # @return [Ruil::MongoResource]
    #   the resource for the collection
    def self.[](collection_name)
      @@resources[collection_name]
    end

  end

end
