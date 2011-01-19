module Ruil

  # Ruil::ModelResource objets defines an extensible basic CRUD
  # interface based on REST. Also, Ruil::ModelResource objects
  # follow the Ruil::Resource interface, that is, they have the
  # call and the === methods.
  #
  # ==== Usage
  #
  #     # Creates a new model resource.
  #     model_resource = Ruil::ModelResource.new
  #
  #     # Prints the response for a request.
  #     if model_resource === env
  #       puts model_resource.call(env)
  #     end
  #
  # A Ruil::ModelResource default path corresponds to the mode
  # table name. Thus, the path for a model with table_name users
  # is /users. The CRUD implementations follows the REST pattern.
  # For example:
  #
  # - <tt>GET /users/list</tt> => lists first page of users users
  # - GET /users/list?page=2 => lists second page of users
  # - GET /users/id/23 => shows the user with id 23.
  # - POST /users => creates a new user.
  #   Parameters are passed using the application/x-www-form-urlencoded media type.
  # - PUT /users/id/23 => creates or update the user with id 23.
  # - DELETE /users/id/23 => deletes the user with id 23.
  class ModelResource

    # Create a new resource.
    #
    # ==== Parameters:
    #
    # - *model* is the model class associated with the controller.
    #   Commonly a model is class derivated from Sequel::Model, but also
    #   clould be a class that satisfy its interface.
    #
    # - *template_dir* indicates where template files are. By default
    #   templates are stored in /dynamic/templates/{table_name}/,
    #   where table_name is readed from the model method table_name.
    #   Inside that directory, files are named by the convesion
    #   {action}.{key}.{engine}.{format} where action specify one of
    #   the CRUD actions (list, show, create, update and delete), key is
    #   specify a mode for rendering the resource (as desktop, mobile,...),
    #   engine specify one of the supported engines (tenjin at this moment)
    #   and format specify the media type of the resource (html, xml, json).
    def initialize(model, template_dir = nil)
      @model        = model
      @template_dir = template_dir || "dynamic/templates/#{@model.table_name}"
      @delegator = Ruil::Delegator.new do |d|
        d << list_resource
        d << show_resource
        d << create_resource
        d << update_resource
        d << delete_resource
      end
    end

    # Call the resource.
    def call(env)
      @delegator.call(env)
    end

    # List model instances.
    def list_resource
      Ruil::ModelResourceLister.new do |r|
        # TODO
      end
    end

    # Show a model instance.
    def show_resources
      Ruil::ModelResourceShower.new do |r|
        # TODO
      end
    end

    # Add a model instance.
    def create_resource
      Ruil::ModelResourceCreator.new do |r|
        # TODO
      end
    end

    # Update a model instance.
    def update_resource
      Ruil::ModelResourceUpdator.new do |r|
        # TODO
      end
    end

    # Delete a model instance.
    def delete_resource
      Ruil::ModelResourceDeletor.new do |r|
        # TODO
      end
    end

  end

end
