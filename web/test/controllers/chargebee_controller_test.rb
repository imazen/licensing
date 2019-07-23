require 'test_helper'

class ChargebeeControllerTest < ActionDispatch::IntegrationTest
  setup do
    VCR.insert_cassette('chargebee')
  end

  teardown do
    VCR.eject_cassette
  end

  test "forbidden without key" do
    post chargebee_index_url, params: load_chargebee_params('subscription_created').reject { |k| k == :key }
    assert_response :forbidden
  end

  test "subscription_created webhook" do
    post chargebee_index_url, params: load_chargebee_params('subscription_created')
    assert_response :no_content
    #assert_subscription_valid
  end

  def load_chargebee_params(event_type)
    file_name = "#{event_type}.json"
    path = Rails.root.join('test', 'fixtures', 'chargebee', file_name)
    JSON.parse(File.read(path)).merge(key: 'test')
  end
end
