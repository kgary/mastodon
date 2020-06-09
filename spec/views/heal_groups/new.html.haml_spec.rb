require 'rails_helper'

RSpec.describe "heal_groups/new", type: :view do
  before(:each) do
    assign(:heal_group, HealGroup.new())
  end

  it "renders new heal_group form" do
    render

    assert_select "form[action=?][method=?]", heal_groups_path, "post" do
    end
  end
end
