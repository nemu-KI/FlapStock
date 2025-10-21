class AddLastBatchAlertSentToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :last_batch_alert_sent, :datetime
  end
end
