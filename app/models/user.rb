class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
           foreign_key: "follower_id",
           dependent:
             :destroy
  has_many :passive_relationships, class_name: "Relationship",
          foreign_key: "followed_id",
          dependent:
            :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  #позволяет читать и записывать переменную. то есть определяет ее
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save
  :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true #в хэз_секюр_пас проверяется
  # наличие пароля и нил не пойдет, поэтому здесь строка позволяет нам второй раз не заполнять
  # при изменении профиля. странно - разберусь


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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end


  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token #создаем новый токен - ресет токен
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest, User.digest(reset_token)) #добавляем его в аттрибут под именем ресет диджест
    # update_attribute(:reset_sent_at, Time.zone.now) #обновляем аттрибут ресет сделан в(время)
  end


  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now #ф-я пасс_ресет в юзер_мейлере с деливер нау(встроенное)
  end


  # Returns true if a password reset has expired. у юзера есть параметр ресет_сент_эт, его сравниваем с 2 часа назад
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  def feed
    following_ids = "SELECT followed_id FROM relationships
WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    following << other_user
  end
  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end
  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end
  private
  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end