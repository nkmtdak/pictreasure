class User < ApplicationRecord
  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連付け
  has_many :challenges
  has_many :photos, through: :challenges
  has_one_attached :avatar

  # バリデーション
  validates :role, presence: true
  validates :username, presence: true, uniqueness: true
  validates :username, format: {
    with: /\A[a-zA-Z0-9_\p{Han}\p{Hiragana}\p{Katakana}ー－]+\z/,
    message: 'only allows letters, numbers, underscores, and Japanese characters'
  }

  # 役割の定義
  enum role: { challenger: 0, master: 1 }

  # スコープの定義（必要に応じて）
  scope :challengers, -> { where(role: :challenger) }
  scope :masters, -> { where(role: :master) }

  # ヘルパーメソッド

  def challenger?
    role == 'challenger'
  end

  def master?
    role == 'master'
  end

  def completed_challenges
    challenges.where(status: 'completed')
  end
end