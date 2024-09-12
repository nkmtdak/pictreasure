class User < ApplicationRecord
  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連付け
  has_many :challenges
  has_many :photos, through: :challenges
  has_one_attached :avatar

  # バリデーション
  validates :username, presence: true, uniqueness: true
  validates :username, format: { 
    with: /\A[a-zA-Z0-9_]+\z/, 
    message: "only allows letters, numbers, and underscores" 
  }

  # 列挙型
  enum user_role: { regular: 0, admin: 1 }

  # スコープ
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :admins, -> { where(user_role: :admin) }

  # コールバック
  after_create :send_welcome_email

  # インスタンスメソッド
  def admin?
    user_role == 'admin'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_challenges
    challenges.where(status: 'active')
  end

  def completed_challenges
    challenges.where(status: 'completed')
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end