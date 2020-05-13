# rubocop:disable Rails/ApplicationController
class ErrorsController < ActionController::Base
  layout "error_page"

  def error_400
    error_response(400, "Bad Request")
  end

  def error_403
    error_response(403, "403 Forbidden")
  end

  def error_404
    error_response(404, "404 Not Found")
  end

  def error_422
    error_response(422, "422 Unprocessable Entity")
  end

  def error_500
    error_response(500, "500 Internal Server Error")
  end

  def error_503
    error_response(503, "503 Service Unavailable")
  end

private

  def json_error(message)
    {
      _response_info: {
        status: "error",
        message: message,
      },
    }
  end

  def error_response(status_code, message)
    respond_to do |format|
      format.html { render status: status_code }
      format.json { render status: status_code, json: json_error(message) }
      format.any  { render status: status_code, text: message }
    end
  end
end
# rubocop:enable Rails/ApplicationController
