class ApplicationController < ActionController::API
  
  private 

  def render_error(error_message, response_code, details={})
    render json: { message: error_message }.merge(details), status: response_code
  end
end
