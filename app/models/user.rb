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
    with: /\A[a-zA-Z0-9_\p{Han}\p{Hiragana}\p{Katakana}ー－]+\z/,
    message: 'only allows letters, numbers, underscores, and Japanese characters'
  }

  # 列挙型
  enum role: { regular: 0, admin: 1 }

  # スコープ
  scope :admins, -> { where(role: :admin) }

  # インスタンスメソッド
  def admin?
    role == 'admin'
  end

  def active_challenges
    challenges.where(status: 'active')
  end

  def completed_challenges
    challenges.where(status: 'completed')
  end
end
