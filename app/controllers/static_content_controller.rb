#encoding: utf-8

class StaticContentController < ActionController::Base
  layout "error_page"

  def error_404
    message = "404 Not Found"
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render status: 404, json: json_error(message) }
      format.any  { render status: 404, text: message }
    end
  end

  def error_422
    message = "422 Unprocessable Entity"
    respond_to do |format|
      format.html { render status: 422 }
      format.json { render status: 422, json: json_error(message) }
      format.any  { render status: 422, text: message }
    end
  end

  def error_500
    message = "500 Internal Server Error"
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render status: 500, json: json_error(message) }
      format.any  { render status: 500, text: message }
    end
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
end
