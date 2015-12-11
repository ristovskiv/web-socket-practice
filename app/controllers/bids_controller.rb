class BidsController < ApplicationController
  def create
    service = PlaceBid.new bid_params
    if service.execute
      flash[:notice] = 'Bid successfully placed.'
      redirect_to product_path(params[:product_id])
    else
      flash[:alert] = "Something went wrong."
      redirect_to product_path(params[:product_id])
    end
  end

  private

  def bid_params
    params.require(:bid).permit(:value).merge!(
      user_id: current_user.id, 
      auction_id: params[:auction_id]
    )
  end
end