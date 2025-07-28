class User < ApplicationRecord
  belongs_to :company
  has_many :stock_movements

  # 仮想属性（フォーム用）
  attr_accessor :company_name

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 新規登録時の会社処理（バリデーション前に実行）
  before_validation :find_or_create_company, on: :create

  private

  def find_or_create_company
    return unless company_name.present?

    # 正規化して検索（前後の空白除去、連続空白を単一空白に）
    normalized_name = company_name.strip.gsub(/[[:space:]]+/, ' ')
    self.company = Company.find_or_create_by(name: normalized_name) do |c|
      c.email = "#{normalized_name}@example.com"
      c.active = true
    end
  end
end
