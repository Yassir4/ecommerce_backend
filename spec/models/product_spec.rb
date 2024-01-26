require 'rails_helper'

RSpec.describe Product, type: :model do
before :example do
  @user = FactoryBot.create(:user)
  @order = FactoryBot.create(:order, user: @user)
  @product = FactoryBot.create(:product)
end

  it "it validates valid attributes" do
    expect(@product).to be_valid
  end

  it 'is invalid without a name' do 
    @product.name = nil
    expect(@product).not_to be_valid
    expect(@product.valid?).to eq false
  end

end
