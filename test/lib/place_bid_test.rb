require 'test_helper'
require 'place_bid'

class PlaceBidTest < Minitest::Test

  def test_it_places_a_bid
    user = User.create!(email:"ristovski_vlatko@yahoo.com", password: "password")
    another_user = User.create!(email: "another_user@yahoo.com", password: "password")
    product = Product.create!(name: "Product", user_id: user.id)
    auction = Auction.create!(value: 10, product_id: product.id)

    service = PlaceBid.new(value: 11, user_id: another_user.id, auction_id: auction.id)

    service.execute

    assert_equal(11, auction.current_bid)
  end

end
