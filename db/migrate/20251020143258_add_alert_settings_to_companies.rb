class AddAlertSettingsToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :email_notifications_enabled, :boolean
    add_column :companies, :notification_frequency, :string
    add_column :companies, :notification_time, :string
    add_column :companies, :notification_recipients, :text
  end
end
