class Api::V1::Restaurants::ImportFilesController < ApplicationController
  before_action :set_file

  REQUIRED_PARAMS = [
    "file"
  ].freeze

  def upload_json
    json_data = JSON.parse(@file.read)
    errors = ::Restaurants::ImportService.new(json_data).serialize_and_persist
    
    return head :no_content if errors.blank?

    render_error("Failed to upload file!", :unprocessable_entity, { errors: errors } )
  rescue JSON::ParserError
    render_error("Invalid JSON file", :unprocessable_entity)
  end

  def set_file
    @file = params["file"]
    render_error("No file provided.", :bad_request) if @file.nil?
  end
end
