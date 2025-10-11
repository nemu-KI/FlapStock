# frozen_string_literal: true

# 発注管理モデル
class Order < ApplicationRecord
  # アソシエーション
  belongs_to :company
  belongs_to :supplier
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items

  # バリデーション
  validates :status, presence: true, inclusion: { in: %w[pending sent confirmed received cancelled] }
  validates :order_items, presence: true

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[order_date status supplier_id user_id created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[supplier user]
  end

  # ステータスのEnum定義
  enum status: {
    pending: 'pending', # 未送信（メール作成のみ）
    sent: 'sent',           # 送信済み
    confirmed: 'confirmed', # 確認済み（発注先から返信あり）
    received: 'received',   # 入荷済み
    cancelled: 'cancelled'  # キャンセル
  }, _prefix: true

  # スコープ
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: 'cancelled') }
  scope :pending_or_sent, -> { where(status: %w[pending sent]) }

  # 発注日を自動設定
  before_create :set_order_date, if: -> { order_date.nil? }

  private

  def set_order_date
    self.order_date = Date.current
  end
end
