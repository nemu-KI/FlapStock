# frozen_string_literal: true

# お問い合わせモデル
class Contact < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :category, presence: true, inclusion: { in: %w[bug feature other] }
  validates :priority, inclusion: { in: %w[high medium low] }
  validates :status, inclusion: { in: %w[pending in_progress completed] }
  validates :subject, presence: true, length: { maximum: 200 }
  validates :message, presence: true, length: { maximum: 2000 }

  enum category: { bug: 'bug', feature: 'feature', other: 'other' }
  enum priority: { high: 'high', medium: 'medium', low: 'low' }
  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed' }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_status, ->(status) { where(status: status) }

  def category_label
    category_labels = {
      'bug' => 'バグ報告',
      'feature' => '機能要望',
      'other' => 'その他'
    }
    category_labels[category]
  end

  def priority_label
    priority_labels = {
      'high' => '高',
      'medium' => '中',
      'low' => '低'
    }
    priority_labels[priority]
  end

  def status_label
    status_labels = {
      'pending' => '未対応',
      'in_progress' => '対応中',
      'completed' => '完了'
    }
    status_labels[status]
  end
end
