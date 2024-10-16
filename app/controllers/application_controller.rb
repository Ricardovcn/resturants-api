class ApplicationController < ActionController::API
  
  private 

  def render_error(error_message, response_code)
    render json: { message: error_message }, status: response_code
  end
end
