# frozen_string_literal: true

RSpec.shared_context "with API" do
  let(:payload) { JSON last_response.body, symbolize_names: true }
end
