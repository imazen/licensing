require 'test_helper'

class ChargebeeControllerTest < ActionDispatch::IntegrationTest
  test "forbidden without key" do
    VCR.use_cassette("missing_key") do
      post chargebee_index_url, params: load_chargebee_params('subscription_created').reject { |k| k == :key }
      assert_response :forbidden
    end
  end

  test "subscription_created webhook" do
    VCR.use_cassette("subscription_created") do
      post chargebee_index_url, params: load_chargebee_params('subscription_created')
      assert_response :no_content
    end
  end

  test "subscription_activated webhook" do
    VCR.use_cassette("subscription_activated") do
      post chargebee_index_url, params: load_chargebee_params('subscription_activated')
      assert_response :no_content
    end
  end

  test "subscription_cancelled webhook" do
    VCR.use_cassette("subscription_cancelled") do
      post chargebee_index_url, params: load_chargebee_params('subscription_cancelled')
      assert_response :no_content
    end
  end

  test "subscription_changed webhook" do
    VCR.use_cassette("subscription_changed") do
      post chargebee_index_url, params: load_chargebee_params('subscription_changed')
      assert_response :no_content
    end
  end

  test "subscription_reactivated webhook" do
    VCR.use_cassette("subscription_reactivated") do
      post chargebee_index_url, params: load_chargebee_params('subscription_reactivated')
      assert_response :no_content
    end
  end

  test "subscription_renewed webhook" do
    VCR.use_cassette("subscription_renewed") do
      post chargebee_index_url, params: load_chargebee_params('subscription_renewed')
      assert_response :no_content
    end
  end

  def load_chargebee_params(event_type)
    file_name = "#{event_type}.json"
    path = Rails.root.join('test', 'fixtures', 'chargebee', file_name)
    key = ENV["CHARGEBEE_WEBHOOK_TOKEN"]
    JSON.parse(File.read(path)).merge(key: key)
  end
end
