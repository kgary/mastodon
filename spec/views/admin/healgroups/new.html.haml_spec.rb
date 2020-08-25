require 'rails_helper'

RSpec.describe "admin/healgroups/new", type: :view do
  before(:each) do
    assign(:admin_healgroup, Admin::Healgroup.new(
      :name => "MyString"
    ))
  end

  it "renders new admin_healgroup form" do
    render

    assert_select "form[action=?][method=?]", admin_healgroups_path, "post" do

      assert_select "input[name=?]", "admin_healgroup[name]"
    end
  end
end
