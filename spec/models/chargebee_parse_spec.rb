require 'rails_helper'

RSpec.describe 'ChargebeeParse' do
  subject { ChargebeeParse.new({"content" => content}) }
  let(:content) {
    { "subscription" => subscription_data }
  }

  describe '#licensed_domains' do
    let(:subscription_data) {
      { "cf_licensed_domains" => domains.join(" ") }
    }
    let(:domains) { ['example.com', 'also.example.com'] }

    it 'returns an array of domains' do
      expect(subject.licensed_domains).to eq domains
    end
  end
end
