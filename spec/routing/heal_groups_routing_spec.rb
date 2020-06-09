require "rails_helper"

RSpec.describe HealGroupsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/heal_groups").to route_to("heal_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/heal_groups/new").to route_to("heal_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/heal_groups/1").to route_to("heal_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/heal_groups/1/edit").to route_to("heal_groups#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/heal_groups").to route_to("heal_groups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/heal_groups/1").to route_to("heal_groups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/heal_groups/1").to route_to("heal_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/heal_groups/1").to route_to("heal_groups#destroy", :id => "1")
    end
  end
end
