# frozen_string_literal: true

# User
class User < ApplicationRecord
  belongs_to :company
  has_many :stock_movements, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  # 仮想属性（フォーム用）
  attr_accessor :company_name

  # 権限の定義
  enum role: { staff: 0, manager: 1, admin: 2 }

  # バリデーション
  validates :name, presence: true
  validates :per_page,
            numericality: { only_integer: true, allow_nil: true, greater_than: 0, less_than_or_equal_to: 200 }
  # ほかの表示設定は将来のため保持（現時点ではバリデーション適用なし）

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # 全ユーザーをadminに設定（MVPリリース期間中）
  before_validation :set_admin_role, on: :create
  # 新規登録時の会社処理（バリデーション前に実行）
  before_validation :find_or_create_company, on: :create
  # trackableカラムのデフォルト値を設定
  before_validation :set_trackable_defaults, on: :create
  # 確実に権限を設定（フォールバック）
  after_create :ensure_admin_role

  private

  def find_or_create_company
    return unless company_name.present?

    # 正規化して検索（前後の空白除去、連続空白を単一空白に）
    normalized_name = company_name.strip.gsub(/[[:space:]]+/, ' ')
    self.company = Company.find_or_create_by(name: normalized_name) do |c|
      c.email = "#{normalized_name.gsub(/\s+/, '')}@example.com"
      c.active = true
      c.timezone = 'Tokyo'
    end
  rescue StandardError => e
    # 会社作成に失敗した場合のエラーハンドリング
    Rails.logger.error "Company creation failed: #{e.message}"
    errors.add(:company_name, '会社の作成に失敗しました')
  end

  def set_admin_role
    # MVPリリース期間中は全ユーザーをadminに設定
    # 将来的には招待コードや設定画面で権限を管理
    Rails.logger.info "Setting admin role for user: #{email}"
    self.role = :admin
  end

  def ensure_admin_role
    # フォールバック: 権限が設定されていない場合はadminに設定
    return unless role.blank? || role == 'staff'

    Rails.logger.info "Ensuring admin role for user: #{email}"
    update_column(:role, :admin)
  end

  def set_trackable_defaults
    self.sign_in_count ||= 0
  end

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[id email role company_id created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[company stock_movements]
  end

  private_class_method :ransackable_attributes, :ransackable_associations
end
