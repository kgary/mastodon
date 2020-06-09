require 'rails_helper'

RSpec.describe "heal_groups/show", type: :view do
  before(:each) do
    @heal_group = assign(:heal_group, HealGroup.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
