require 'rails_helper'

RSpec.describe "heal_groups/edit", type: :view do
  before(:each) do
    @heal_group = assign(:heal_group, HealGroup.create!())
  end

  it "renders the edit heal_group form" do
    render

    assert_select "form[action=?][method=?]", heal_group_path(@heal_group), "post" do
    end
  end
end
