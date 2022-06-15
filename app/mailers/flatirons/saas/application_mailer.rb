# frozen_string_literal: true

module Flatirons
  module Saas
    class ApplicationMailer < ActionMailer::Base
      default from: 'from@example.com'
      layout 'mailer'
    end
  end
end
