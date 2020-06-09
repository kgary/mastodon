require 'rails_helper'

RSpec.describe "HealGroups", type: :request do
  describe "GET /heal_groups" do
    it "works! (now write some real specs)" do
      get heal_groups_path
      expect(response).to have_http_status(200)
    end
  end
end
