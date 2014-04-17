class MappingsBatchWorker
  include Sidekiq::Worker

  def perform(mappings_batch_id)
    batch = MappingsBatch.find(mappings_batch_id)
    Transition::History.as_a_user(batch.user) do
      batch.process
    end
  end
end
