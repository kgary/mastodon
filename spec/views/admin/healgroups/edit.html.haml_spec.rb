require 'rails_helper'

RSpec.describe "admin/healgroups/edit", type: :view do
  before(:each) do
    @admin_healgroup = assign(:admin_healgroup, Admin::Healgroup.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit admin_healgroup form" do
    render

    assert_select "form[action=?][method=?]", admin_healgroup_path(@admin_healgroup), "post" do

      assert_select "input[name=?]", "admin_healgroup[name]"
    end
  end
end
