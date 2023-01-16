class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }


  # Returns the hash digest of the given string. закриптованный новый пароль с ценой кост(встроенно)
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  # Returns a random token. Создает защищенный рандомный токен 22 символа (64 вариации)с помощью встроенная функция
  def User.new_token
    SecureRandom.urlsafe_base64
  end


  # Remembers a user in the database for use in persistent sessions. учебник говорит, селф перед переменной - к тому,
  # чтобы переменная не была локальной
  def remember
    self.remember_token = User.new_token #присваиваем классу параметр ремембер_токен, который равен созданному ф-ей
    # класса новому токену
      update_attribute(:remember_digest, User.digest(remember_token)) #заменяем в текущего юзера параметр
  #   ремембер_дайджест со значением созданным ф-ей юзер.дайджест на основе ремембер токена
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end