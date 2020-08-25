require 'rails_helper'

RSpec.describe "Admin::Healgroups", type: :request do
  describe "GET /admin/healgroups" do
    it "works! (now write some real specs)" do
      get admin_healgroups_path
      expect(response).to have_http_status(200)
    end
  end
end
