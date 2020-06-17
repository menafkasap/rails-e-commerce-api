class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  private

  def json_response(data, status_code = '200')
    { status: status_code, data: data}
  end

  def json_response_with_include(data, includes, status_code = '200')
    { status: status_code, data: data, includes: includes}
  end
end
