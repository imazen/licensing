require 'rails_helper'

RSpec.describe 'ChargebeeParse' do
  subject { ChargebeeParse.new(params) }

  describe '#licensed_domains' do
    let(:params) { {
      "content" => {
        "subscription" => {
          "cf_licensed_domains" => "example.com also.example.com"
        }
      }
    } }

    it 'returns an array of domains' do
      expect(subject.licensed_domains).to eq ['example.com', 'also.example.com']
    end
  end
end
