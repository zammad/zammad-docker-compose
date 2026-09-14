Rails.application.config.to_prepare do
  Ticket.class_eval do
    after_create :hotfix_log_ticket_create

    def hotfix_log_ticket_create
      Rails.logger.error "HOTFIX EXAMPLE: Ticket ##{number} (id #{id}) was created by user id #{created_by_id}"
    end
  end
end
