class MappingsBatchWorker
  include Sidekiq::Worker

  def perform(mappings_batch_id)
    batch = MappingsBatch.find_by_id(mappings_batch_id)
    return if batch.nil?
    Transition::History.as_a_user(batch.user) do
      batch.process
    end
  end
end
