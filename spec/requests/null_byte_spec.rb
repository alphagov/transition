require "rails_helper"

describe "NullByteSpec", type: :request do
  it "does not error when provided with null bytes in the session cookie" do
    cookies["_session_id"] = "123\u0000"

    expect {
      get "/"
    }.not_to raise_error(ArgumentError, "string contains null byte")
  end
end
