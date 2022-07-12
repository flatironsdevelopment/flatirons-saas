# frozen_string_literal: true

require 'rails_helper'

module Flatirons::Saas
  RSpec.describe Product, type: :model do
    describe 'validations' do
      it { should validate_presence_of(:name) }
    end
  end
end
