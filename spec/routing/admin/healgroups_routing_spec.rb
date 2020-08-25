require "rails_helper"

RSpec.describe Admin::HealgroupsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin/healgroups").to route_to("admin/healgroups#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/healgroups/new").to route_to("admin/healgroups#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/healgroups/1").to route_to("admin/healgroups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/healgroups/1/edit").to route_to("admin/healgroups#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/admin/healgroups").to route_to("admin/healgroups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/admin/healgroups/1").to route_to("admin/healgroups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/admin/healgroups/1").to route_to("admin/healgroups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin/healgroups/1").to route_to("admin/healgroups#destroy", :id => "1")
    end
  end
end
