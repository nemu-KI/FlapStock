# frozen_string_literal: true

# Company
class Company < ApplicationRecord
  has_many :categories, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\d\-+()\s]+\z/, message: 'は有効な電話番号ではありません' }, allow_blank: true
  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  # デフォルト値の設定
  after_initialize :set_default_timezone, if: :new_record?

  # アラート設定のバリデーション
  validates :notification_frequency, inclusion: { in: %w[immediate daily weekly], allow_blank: true }
  validates :notification_time, format: { with: /\A([01]?[0-9]|2[0-3]):[0-5][0-9]\z/, message: 'はHH:MM形式で入力してください' },
                                allow_blank: true

  # アラート設定のヘルパーメソッド
  def notification_recipients_list
    return [] if notification_recipients.blank?

    JSON.parse(notification_recipients)
  rescue JSON::ParserError
    []
  end

  def notification_recipients_list=(user_ids)
    # user_idsがnilまたは空の場合は空のJSON配列を設定
    self.notification_recipients = if user_ids.nil? || user_ids.empty?
                                     [].to_json
                                   else
                                     user_ids.reject(&:blank?).to_json
                                   end
  end

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name email phone address timezone active created_at updated_at email_notifications_enabled
       notification_frequency notification_time notification_recipients]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[categories locations suppliers items users stock_movements orders]
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  private

  def set_default_timezone
    self.timezone ||= 'Tokyo'
  end
end
