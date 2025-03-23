# frozen_string_literal: true

RSpec.describe Pebble do
  it "has a version number" do
    expect(Pebble::VERSION).not_to be nil
  end
end

RSpec.describe Pebble::Application do
  it "returns a simple response" do
    app = Pebble::Application.new
    response = app.call({})
    expect(response).to eq([200, { "content-type" => "text/plain" }, ["Hello, World!"]])
  end
end
