require 'rails_helper'

RSpec.describe "admin/healgroups/show", type: :view do
  before(:each) do
    @admin_healgroup = assign(:admin_healgroup, Admin::Healgroup.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
