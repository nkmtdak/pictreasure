class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :challenges

  validates :username, presence: true, uniqueness: true
  
  enum role: { user: 0, admin: 1 } # role カラムの定義に基づいて適切に設定
end
