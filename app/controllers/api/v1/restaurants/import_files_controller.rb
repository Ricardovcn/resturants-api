class Api::V1::Restaurants::ImportFilesController < ApplicationController
  before_action :set_file, :validate_file_extension 

  ALLOWED_EXTENSIONS = %w[.json]

  REQUIRED_PARAMS = [
    "file"
  ].freeze

  def import_json
    json_data = JSON.parse(@file.read)
    errors = ::Restaurants::ImportService.new(json_data).serialize_and_persist
    
    return head :no_content if errors.blank?

    render_error("Failed to import file.", :unprocessable_entity, { errors: errors } )
  rescue JSON::ParserError
    render_error("Invalid JSON file.", :unprocessable_entity)
  end

  def set_file
    @file = params["file"]
    render_error("No file provided.", :bad_request) if @file.nil?
  end

  def validate_file_extension
    extension = File.extname(@file.original_filename.to_s)

    unless ALLOWED_EXTENSIONS.include?(extension)
      return render_error("Invalid file extension. File must be one of the following types: #{ALLOWED_EXTENSIONS.join(', ')}", :unprocessable_entity)
    end
  end
end
