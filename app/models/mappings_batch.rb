class MappingsBatch < ActiveRecord::Base
  self.inheritance_column = :klass

  FINISHED_STATES = ['succeeded', 'failed']
  PROCESSING_STATES = ['unqueued', 'queued', 'processing'] + FINISHED_STATES

  attr_accessible :tag_list, :update_existing, :state

  belongs_to :user
  belongs_to :site
  has_many :entries, foreign_key: :mappings_batch_id, class_name: 'MappingsBatchEntry', dependent: :delete_all

  validates :user, presence: true
  validates :site, presence: true
  validates :state, inclusion: { :in => PROCESSING_STATES }

  scope :reportable, where(seen_outcome: false).where("state != 'unqueued'")

  def entries_to_process
    if update_existing
      entries
    else
      entries.without_existing_mappings
    end
  end

  def finished?
    FINISHED_STATES.include?(state)
  end

  def succeeded?
    state == 'succeeded'
  end

  def failed?
    state == 'failed'
  end

  def with_state_tracking
    update_column(:state, 'processing')
    yield
    update_column(:state, 'succeeded')
  rescue => e
    update_column(:state, 'failed')
    raise
  end
end
