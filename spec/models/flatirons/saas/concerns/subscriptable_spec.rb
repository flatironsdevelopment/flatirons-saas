# frozen_string_literal: true

require 'rails_helper'

describe Flatirons::Saas::Concerns::Subscriptable do
  include_context 'with_organization_model'

  it 'can be accessed as a constant' do
    expect(Organization).to be
  end

  it 'should be subscriptable' do
    expect(Organization.subscriptable?).to be true
  end

  it 'should not include subscriptable twice' do
    expect(Organization.subscriptable).to be_nil
  end

  context 'Organization' do
    context 'without subscriptions' do
      it 'should return 0' do
        expect(Organization.count).to eq(1)
        expect(organization.subscriptions.count).to eq(0)
      end
    end

    context 'with subscriptions' do
      let!(:subscription) { FactoryBot.create(:subscription, subscriptable: organization) }

      it 'should return 1' do
        expect(Organization.count).to eq(1)
        expect(organization.subscriptions.count).to eq(1)
      end
    end
  end
end
