# frozen_string_literal: true

require 'rails_helper'

describe 'Productable' do
  with_model :SomeProduct do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      productable
    end
  end

  describe 'validations' do
    it 'validates name' do
      some_product = SomeProduct.new
      expect(some_product.valid?).to eq(false)
      some_product.errors.full_messages.include? "Name can't be blanks"
    end
  end

  it 'can be accessed as a constant' do
    expect(SomeProduct).to be
  end

  it 'should be productable' do
    expect(SomeProduct.productable?).to be true
  end
end
