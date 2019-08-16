require 'rails_helper'

RSpec.describe ChargebeeLicenseGenerator do
  let(:cb) { ChargebeeParse.new(cb_params) }
  let(:cb_params) {
    { "content" => { "subscription" => subscription_params } }
  }
  let(:subscription_params) { { "current_term_end" => 1565926099 } }
  let(:seed) { 'foo' }
  let(:key) { '123acab' }
  let(:passphrase) { 'overthrowcapitalism' }
  let(:generator) { described_class.new(cb, seed, key, passphrase) }
  let(:license) {
    { :encoded=>
      "License 1056624108 for test company (Imageflow Site License) :SWQ6IDEwNTY2MjQxMDgKT3duZXI6IHRlc3QgY29tcGFueQpLaW5kOiBvZW0KSXNzdWVkOiAyMDE3LTA1LTA0VDAyOjU4OjUyKzAwOjAwCkV4cGlyZXM6IDIwMTctMDYtMDdUMDI6NTg6NTMrMDA6MDAKRmVhdHVyZXM6IFJfRWxpdGUgUl9DcmVhdGl2ZSBSX1BlcmZvcm1hbmNlClByb2R1Y3Q6IEltYWdlZmxvdyBTaXRlIExpY2Vuc2UKTXVzdEJlRmV0Y2hlZDogdHJ1ZQpJc1B1YmxpYzogdHJ1ZQpSZXN0cmljdGlvbnM6IFNpbmdsZS1wcm9kdWN0IE9FTSByZWRpc3RyaWJ1dGlvbi4gT25seSBmb3Igb3JnYW5pemF0aW9ucyB3aXRoIGZld2VyIHRoYW4gNTAwIGVtcGxveWVlcy4=:HBN2ZNG1ybvLFV67OEtNvPIhWjZZMEiN6v0HoDysUeVvin9rihzXnQSzkzeI1kmeWYPhoR+P2qAf2EUibfY5S0y4d1nLt0Je4UGO3ApAEn57sKauEZbDYxYSyzFQX202M4NEQjZdsRSu/bx6pE1PcvheS9nqXOAYYzJ2c9o6Kieli9emYtEINJf+muyoYrx02jw/DTzk8Mvkf1/BXtRgpHKuJGcAdWtcQ5+gqgqI+wTqf6cznnCjdzf/Jyve81cosonKnVfec+FAVw9CgzWLeGRsxH9/x3n3g+0i9nsL52vnHpP7ohvvCMIVY8HTVO2/f03y6jkwQHPScukgmO9DRw==",
        :summary=>"License 1056624108 for test company (Imageflow Site License)",
        :text=>
      "Id: 1056624108\nOwner: test company\nKind: oem\nIssued: 2017-05-04T02:58:52+00:00\nExpires: 2017-06-07T02:58:53+00:00\nFeatures: R_Elite R_Creative R_Performance\nProduct: Imageflow Site License\nMustBeFetched: true\nIsPublic: true\nRestrictions: Single-product OEM redistribution. Only for organizations with fewer than 500 employees." }
  }

  before {
    allow(ImazenLicensing::LicenseGenerator).to receive(:generate_with_info).and_return(license)
    meta_data = { kind: 'foo', features: 'bar', is_public: true }
    allow(cb).to receive(:plan).and_return(double(meta_data: meta_data, invoice_name: 'Bob'))
  }

  describe '#generate_license' do
    subject { generator.generate_license }

    it 'returns a license represented by a hash' do
      license_keys = [:id, :license, :id_license, :secret]
      expect(subject).to be_a Hash
      expect(subject.keys).to match_array license_keys
    end
  end

  describe '#maybe_send_license_email' do
    let(:subscription_params) { { "current_term_end" => 1565926099, "cf_license_hash" => cf_license_hash } }

    context 'subscription cf_license_hash matches encoded license' do
      let(:cf_license_hash) { Digest::SHA256.hexdigest(license[:encoded]) }

      it 'does not send new license email' do
        expect(LicenseMailer).to_not receive(:id_license_email)
        generator.maybe_send_license_email
      end
    end

    context 'subscription cf_license_hash does not match encoded license' do
      let(:cf_license_hash) { Digest::SHA256.hexdigest("foo") }

      it 'sends new license email to customer' do
        expect(LicenseMailer).to receive(:id_license_email).and_return(double(deliver_now: true))
        generator.maybe_send_license_email
      end
    end
  end
end
