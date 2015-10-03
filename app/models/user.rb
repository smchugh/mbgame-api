require 'bcrypt'

class User < ActiveRecord::Base
  validates :name, :email, :picture, presence: true
  validates :email, uniqueness: true

  has_and_belongs_to_many :games

  # Create two virtual (in memory only) attributes to hold the password and its confirmation.
  attr_accessor :new_password, :new_password_confirmation
  # We need to validate that the user has typed the same password twice
  # but we only want to do the validation if they've opted to change their password.
  validates_confirmation_of :new_password, :if => :password_changed?

  API_TIMEOUT_SECONDS = 60 * 60 * 24

  def generate_api_key
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.exists?(api_token: token)
    end
  end

  def set_auth
    if not self.api_token or not self.api_token_expiration > DateTime.current
      self.api_token = self.generate_api_key
    end

    self.api_token_expiration = DateTime.current + API_TIMEOUT_SECONDS.seconds
  end

  def self.get_authenticated(email, password)
    user = find_by_email(email)
    if user
      if BCrypt::Password.new(user.password).is_password? password
        return user
      end
    end
    return nil
  end

  before_create do |doc|
    doc.set_auth
  end

  before_save do |doc|
    if doc.password_changed?
      doc.hash_new_password
    end
  end

  # By default the form_helpers will set new_password to "",
  # we don't want to go saving this as a password
  def password_changed?
    !@new_password.blank?
  end

  def show_attributes
    self.attribute_names - [:api_token.to_s, :api_token_expiration.to_s, :password.to_s]
  end

  def to_show_dict
    json_attributes = {}
    self.show_attributes.each do |attribute|
      json_attributes[attribute] = self[attribute]
    end
    json_attributes
  end

  def created_attributes
    self.attribute_names - [:password.to_s]
  end

  def to_created_dict
    json_attributes = {}
    self.created_attributes.each do |attribute|
      json_attributes[attribute] = self[attribute]
    end
    json_attributes
  end

  def active_game
    games.where('games.status = ?', Game::STATUS_ACTIVE).first
  end

  def hash_new_password
    self.password = BCrypt::Password.create(@new_password)
  end
end
