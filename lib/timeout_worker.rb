class TimeoutWorker < BaseWorker
  class Error < ::StandardError; end
  class TimeOutNotSetError < Error; end

  RESCHEDULE_TIME = 30 # minutes

  sidekiq_options queue: 'default'

  def self.start_timeout_clock(ontology_version_id, hours_offset=nil)
    hours_offset ||= timeout_limit
    self.perform_in(hours_offset.hours, ontology_version_id)
  end

  def self.timeout_limit
    raise TimeOutNotSetError unless Settings.ontology_parse_timeout
    Settings.ontology_parse_timeout
  end


  def perform(ontology_version_id)
    version = OntologyVersion.find(ontology_version_id)
    if state_not_terminal?(version)
      version.update_state!('failed', "The job reached the timeout limit of #{self.class.timeout_limit} hours.")
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn <<-MSG
Ontology Version with id <#{ontology_version_id}> could not be found.
Therefore the timeout-job will not continue. It will also not be rescheduled.
    MSG
  end

  def state_not_terminal?(ontology_version)
    !OntologyVersion::States::TERMINAL_STATES.include?(ontology_version.state)
  end

end
