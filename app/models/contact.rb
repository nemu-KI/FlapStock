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
    case category
    when 'bug' then 'バグ報告'
    when 'feature' then '機能要望'
    when 'other' then 'その他'
    end
  end

  def priority_label
    case priority
    when 'high' then '高'
    when 'medium' then '中'
    when 'low' then '低'
    end
  end

  def status_label
    case status
    when 'pending' then '未対応'
    when 'in_progress' then '対応中'
    when 'completed' then '完了'
    end
  end
end
