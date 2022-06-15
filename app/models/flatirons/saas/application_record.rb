# frozen_string_literal: true

module Flatirons
  module Saas
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
