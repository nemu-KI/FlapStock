# frozen_string_literal: true

namespace :alert do
  desc 'Send batch stock alerts for all companies'
  task batch: :environment do
    puts 'Starting batch alert processing...'
    Rails.logger.info 'Starting batch alert processing...'

    companies = Company.where(email_notifications_enabled: true)
    puts "Found #{companies.count} companies with notifications enabled"

    companies.find_each do |company|
      puts "Checking company: #{company.name}"
      puts "  - notification_frequency: #{company.notification_frequency}"
      puts "  - notification_time: #{company.notification_time}"
      puts "  - timezone: #{company.timezone}"

      scheduler = AlertScheduler.new(company)

      if scheduler.should_send_alert?
        puts "  - Sending alerts for #{company.name}"
        Rails.logger.info "Processing alerts for company: #{company.name}"
        scheduler.queue_batch_alerts
      else
        puts "  - Skipping #{company.name} - not time for alerts"
        Rails.logger.debug "Skipping company #{company.name} - not time for alerts"
      end
    end

    puts 'Batch alert processing completed.'
    Rails.logger.info 'Batch alert processing completed.'
  end
end
