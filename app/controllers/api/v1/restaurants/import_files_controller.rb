class Api::V1::Restaurants::ImportFilesController < ApplicationController
  before_action :set_file, :validate_file_extension, :parse_file_data

  ALLOWED_EXTENSIONS = %w[.json]

  REQUIRED_PARAMS = [
    "file"
  ].freeze

  def import_json
    render json: ::Restaurants::SerializeAndPersistService.new(@json_data).call
  rescue StandardError => error
    logger.error "Error importing restaurants: #{error.message}"
    logger.error error.backtrace[0..10].join("\n")
    render_error("Failed to serialize and persist data", :internal_server_error)
  end

  private 

  def parse_file_data
    @json_data = JSON.parse(@file.read)
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
