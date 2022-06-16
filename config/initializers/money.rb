# encoding : utf-8

MoneyRails.configure do |config|
  Money.locale_backend = :i18n
  config.default_currency = :usd
  config.rounding_mode = BigDecimal::ROUND_HALF_EVEN
end
