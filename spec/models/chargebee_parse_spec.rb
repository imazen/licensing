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

  describe '#expires_on' do
    subject { cb.resizer_expires_on }

    context 'without a perpetual add-on' do
      context 'with a cancelled subscription' do
        let(:subscription_data) { { 'created_at' => created_at, 'status' => 'cancelled', 'cancelled_at' => cancel_date } }
        let(:created_at) { Time.parse('2016-01-01').strftime('%s').to_i }

        context 'cancel date is over 3 years past subscription creation' do
          let(:cancel_date) { Time.parse('2019-01-15').strftime('%s').to_i }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'cancel date is less than 3 years past subscription creation' do
          let(:cancel_date) { Time.parse('2018-01-15').strftime('%s').to_i }
          let(:fake_date) { double(advance: 'guess') }
          before {
            allow(cb).to receive(:term_end_guess).and_return(fake_date)
            allow(cb).to receive(:subscription_grace_minutes).and_return(1)
          }

          it 'returns the term end guess' do
            expect(subject).to eq 'guess'
          end
        end
      end

      context 'with a current subscription' do
        let(:subscription_data) { { 'created_at' => created_at, 'status' => 'active' } }
        let(:created_at) { 1.week.ago.strftime('%s').to_i }
        let(:fake_date) { double(advance: 'guess') }

        before {
          allow(cb).to receive(:term_end_guess).and_return(fake_date)
          allow(cb).to receive(:subscription_grace_minutes).and_return(1)
        }

        it 'returns the term end guess' do
          expect(subject).to eq 'guess'
        end
      end
    end

    context 'with a perpetual add-on' do
      let(:subscription_data) {
        { 'created_at' => created_at,
          'status' => 'active',
          'cf_perpetual' => true }
      }
      let(:created_at) { 1.week.ago.strftime('%s').to_i }

      it 'returns nil' do
        expect(subject).to be_nil
      end

      context 'with a recently cancelled subscription' do
        let(:subscription_data) {
          { 'created_at' => created_at,
            'cf_perpetual' => true,
            'status' => 'cancelled',
            'cancelled_at' => cancel_date }
        }
        let(:created_at) { 1.year.ago.strftime('%s').to_i }
        let(:cancel_date) { 1.week.ago.strftime('%s').to_i }

        it 'still returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
