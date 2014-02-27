#encoding: utf-8

class ErrorsController < ActionController::Base
  layout "error_page"

  def error_400
    error_response(400, "Bad Request")
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

private

  def json_error(message)
    {
      _response_info: {
        status: 'error',
        message: message
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
