require 'rails_helper'

RSpec.describe "admin/healgroups/index", type: :view do
  before(:each) do
    assign(:admin_healgroups, [
      Admin::Healgroup.create!(
        :name => "Name"
      ),
      Admin::Healgroup.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of admin/healgroups" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
