class StaticContentController < ApplicationController
  def error_404
    respond_to do |format|
      format.html { render status: 404 }
      format.any  { render text: "404 Not Found", status: 404 }
    end
  end

  def error_500
    render file: "#{Rails.root}/public/500.html", layout: false, status: 500
  end
end
