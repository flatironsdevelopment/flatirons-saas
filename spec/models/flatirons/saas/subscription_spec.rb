# frozen_string_literal: true

require 'rails_helper'

module Flatirons::Saas
  RSpec.describe Subscription, type: :model do
    describe 'validations' do
      it { should validate_presence_of(:stripe_subscription_id) }
      it { should validate_presence_of(:status) }
    end
    describe 'relationships' do
      it { is_expected.to have_db_column(:subscriptable_id).of_type(:integer) }
      it { is_expected.to have_db_column(:subscriptable_type).of_type(:string) }
      it { is_expected.to belong_to(:subscriptable) }
    end
  end
end
