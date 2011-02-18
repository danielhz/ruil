require 'rubygems'
require 'ruil/delegator'
require 'ruil/resource'
require 'ruil/template'
require 'ruil/model'
require 'sequel'

describe Ruil::ModelResource, 'when listing' do

  before(:all) do
    DB = Sequel.sqlite
    DB.create_table :items do
      primary_key :id
      String :name
      Float :price
    end
    class Items < Sequel::Model
    end
    # Insert 100 random records
    # TODO:
  end

  it 'show first page 10 results' do
    # TODO:
    # (use json templates)
  end

  it 'show 3th page' do
    # TODO
  end
end

describe Ruil::ModelResource, 'when showing' do
  # TODO
end

desctibe Ruil::ModelResource, 'when creating' do
  # TODO
end

describe Ruil::ModelResource, 'when updating' do
  # TODO
end

describe Ruil::ModelResource, 'when deleting' do
  # TODO
end
