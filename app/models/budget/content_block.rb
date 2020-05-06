class Budget
  class ContentBlock < ApplicationRecord
    validates :locale, presence: true, inclusion: { in: I18n.available_locales.map(&:to_s) }
    validates :heading, presence: true, uniqueness: { scope: :locale }

    belongs_to :heading
  end
end
