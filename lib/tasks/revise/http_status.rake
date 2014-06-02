require 'transition/revisionism/http_status'

namespace :revise do
  desc 'Replace :http_status in versions with :type'
  task http_status: :environment do
    Transition::Revisionism::HTTPStatus.replace_with_type!
  end
end
