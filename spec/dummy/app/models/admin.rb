class Admin < ApplicationRecord
  has_secure_password

  # == Validations =====================================================================================================
  validates :email, presence: true, uniqueness: true
  validates :email, uniqueness: true, allow_blank: true

  # == Callbacks =======================================================================================================
  before_save :downcase_email, if: -> { email_changed? }

  # == Private methods =================================================================================================
  private

  def downcase_email
    self.email.downcase!
  end
end
