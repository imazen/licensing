require 'rails_helper'

RSpec.describe 'ChargebeeParse' do
  let(:cb) { ChargebeeParse.new({"content" => content}) }
  let(:content) {
    { "subscription" => subscription_data }
  }
  let(:subscription_data) { {} }

  describe '#licensed_domains' do
    let(:subscription_data) {
      { "cf_licensed_domains" => domains.join(" ") }
    }
    let(:domains) { ['example.com', 'also.example.com'] }

    it 'returns an array of domains' do
      expect(cb.licensed_domains).to eq domains
    end
  end

  describe '#domains_required?' do
    subject { cb.domains_required? }
    before { allow(ChargeBee::Plan).to receive(:retrieve).and_return(double(plan: plan)) }
    let(:plan) { double(meta_data: { kind: kind }) }

    context 'when plan kind is per-core-domain' do
      let(:kind) { 'per-core-domain' }

      it { is_expected.to eq true }
    end

    context 'when plan is another kind' do
      let(:kind) { 'some-other-kind' }

      it { is_expected.to eq false }
    end
  end

  describe '#domains_under_min?' do
    subject { cb.domains_under_min? }
    before { allow(ChargeBee::Plan).to receive(:retrieve).and_return(double(plan: plan)) }
    let(:plan) { double(meta_data: { listed_domains_min: min }) }
    let(:min) { 1 }

    context 'when subscription has no domains field' do
      let(:subscription_data) { {} }

      it { is_expected.to eq true }
    end

    context 'when subscription has a domains field' do
      let(:subscription_data) { { 'cf_licensed_domains' => domains } }

      context 'when domains count is less than the min' do
        let(:domains) { '' }

        it { is_expected.to eq true }
      end

      context 'when domains count is equal to the min' do
        let(:domains) { 'foo.example.com' }

        it { is_expected.to eq false }
      end

      context 'when domains count is greater than the min' do
        let(:domains) { 'foo.example.com bar.example.com' }

        it { is_expected.to eq false }
      end
    end
  end

  describe '#domains_over_max?' do
    subject { cb.domains_over_max? }
    before { allow(ChargeBee::Plan).to receive(:retrieve).and_return(double(plan: plan)) }
    let(:plan) { double(meta_data: { listed_domains_max: max }) }
    let(:max) { 2 }

    context 'when subscription has no domains field' do
      let(:subscription_data) { {} }

      it { is_expected.to eq false }
    end

    context 'when subscription has a domains field' do
      let(:subscription_data) { { 'cf_licensed_domains' => domains } }

      context 'when domains count is greater than the max' do
        let(:domains) { 'foo.example.com bar.example.com baz.example.com' }

        it { is_expected.to eq true }
      end

      context 'when domains count is less than the max' do
        let(:domains) { 'example.com' }

        it { is_expected.to eq false }
      end

      context 'when domains count is equal to the max' do
        let(:domains) { 'foo.example.com bar.example.com' }

        it { is_expected.to eq false }
      end
    end
  end

  describe '#message' do
    subject { cb.message }

    it { is_expected.to be_a(Array) }

    context 'after trying to update subscription and customer' do
      context 'with a stale subscription' do
        before do
          allow(cb).to receive(:subscription_stale?).and_return(true)
          allow(ChargeBee::Subscription).to receive(:retrieve).and_return(double(subscription: {}))
          allow(ChargeBee::Customer).to receive(:retrieve).and_return(double(customer: {}))
          cb.maybe_update_subscription_and_customer
        end

        it 'includes a string containing log info' do
          expect(subject).to include(a_string_matching(/Retrieved/))
          expect(subject).to include(a_string_matching(/subscription/))
          expect(subject).to include(a_string_matching(/customer/))
        end
      end

      context 'with a subscription that is not stale' do
        before do
          allow(cb).to receive(:subscription_stale?).and_return(false)
          cb.maybe_update_subscription_and_customer
        end

        it 'includes a string containing log info' do
          expect(subject).to include(a_string_matching(/skipping/))
        end
      end
    end
  end
end
