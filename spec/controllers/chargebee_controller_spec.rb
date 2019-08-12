require 'rails_helper'

RSpec.describe ChargebeeController, type: :controller do
  context 'without a key' do
    it 'is forbidden' do
      post :index, params: load_chargebee_params('subscription_created').reject { |k| k == :key }
      expect(response).to have_http_status :forbidden
    end
  end

  context 'subscription_created webhook' do
    it 'returns no_content' do
      VCR.use_cassette("subscription_created") do
        post :index, params: load_chargebee_params('subscription_created')
        expect(response).to have_http_status :no_content
      end
    end

    context 'subscription requires domains' do
      context 'domains count is ok' do
        it 'does not send domain emails' do
          VCR.use_cassette('domains_count_ok') do
            expect(LicenseMailer).not_to receive(:domains_under_min)
            post :index, params: load_chargebee_params('domains_count_ok')
          end
        end
      end

      context 'domains count is under minimum' do
        it 'sends domains_under_min email' do
          VCR.use_cassette('domains_under_min') do
            expect(LicenseMailer).to receive(:domains_under_min)
            post :index, params: load_chargebee_params('domains_under_min')
          end
        end

        it 'does not send licensing email' do
          VCR.use_cassette('domains_under_min') do
            expect(LicenseMailer).not_to receive(:id_license_email)
            post :index, params: load_chargebee_params('domains_under_min')
          end
        end

        it 'returns no content' do
          VCR.use_cassette('domains_under_min') do
            post :index, params: load_chargebee_params('domains_under_min')
            expect(response).to have_http_status :no_content
          end
        end
      end

      context 'domains count is over maximum' do
        xit 'sends domains_over_max email' do
          expect(LicenseMailer).to receive(:domains_over_max)
          post :index, params: load_chargebee_params('domains_over_max')
        end
      end
    end
  end

  context "subscription_activated webhook" do
    it 'returns no_content' do
      VCR.use_cassette("subscription_activated") do
        post :index, params: load_chargebee_params('subscription_activated')
        assert_response :no_content
      end
    end
  end

  context "subscription_cancelled webhook" do
    it 'returns no_content' do
      VCR.use_cassette("subscription_cancelled") do
        post :index, params: load_chargebee_params('subscription_cancelled')
        assert_response :no_content
      end
    end
  end

  context "subscription_changed webhook" do
    it 'returns no_content' do
      VCR.use_cassette("subscription_changed") do
        post :index, params: load_chargebee_params('subscription_changed')
        assert_response :no_content
      end
    end
  end

  context "subscription_reactivated webhook" do
    it 'returns no_content' do
      VCR.use_cassette("subscription_reactivated") do
        post :index, params: load_chargebee_params('subscription_reactivated')
        assert_response :no_content
      end
    end
  end

  context "subscription_renewed webhook" do
    it 'returns no_content' do
      VCR.use_cassette("subscription_renewed") do
        post :index, params: load_chargebee_params('subscription_renewed')
        assert_response :no_content
      end
    end
  end

  def load_chargebee_params(event_type)
    file_name = "#{event_type}.json"
    path = Rails.root.join('spec', 'fixtures', 'chargebee', file_name)
    key = ENV["CHARGEBEE_WEBHOOK_TOKEN"]
    JSON.parse(File.read(path)).merge(key: key)
  end
end
