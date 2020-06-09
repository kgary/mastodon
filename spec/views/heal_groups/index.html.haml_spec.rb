require 'rails_helper'

RSpec.describe "heal_groups/index", type: :view do
  before(:each) do
    assign(:heal_groups, [
      HealGroup.create!(),
      HealGroup.create!()
    ])
  end

  it "renders a list of heal_groups" do
    render
  end
end
