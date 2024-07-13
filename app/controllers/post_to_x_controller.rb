class PostToXController < ApplicationController
  def create
    service = PostToXService.new
    post_data = service.call

    if post_data
      render json: { status: 'success', message: 'Posted to X successfully', post: post_data }
    else
      render json: { status: 'error', message: 'Failed to post to X' }
    end
  end
end
