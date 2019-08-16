require 'rails_helper'

RSpec.describe ChargebeeLicenseGenerator do
  describe '#generate_license' do
    let(:cb) { ChargebeeParse.new(cb_params) }
    let(:cb_params) {
      { "content" => { "subscription" => { "current_term_end" => 1565926099 } } }
    }
    let(:seed) { 'foo' }
    let(:key) { '123acab' }
    let(:passphrase) { 'overthrowcapitalism' }
    let(:generator) { described_class.new(cb, seed, key, passphrase) }
    subject { generator.generate_license }

    before {
      allow(ImazenLicensing::LicenseGenerator).to receive(:generate_with_info).and_return(:license)
      meta_data = { kind: 'foo', features: 'bar', is_public: true }
      allow(cb).to receive(:plan).and_return(double(meta_data: meta_data, invoice_name: 'Bob'))
    }

    it 'returns a license represented by a hash' do
      license_keys = [:id, :license, :id_license, :secret]
      expect(subject).to be_a Hash
      expect(subject.keys).to match_array license_keys
    end
  end
end
