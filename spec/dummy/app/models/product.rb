# frozen_string_literal: true

class Product < ApplicationRecord
  productable
  validates :name, presence: true
end
