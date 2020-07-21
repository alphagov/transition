class MappingsBatch < ApplicationRecord
  self.inheritance_column = :klass

  FINISHED_STATES = %w[succeeded failed].freeze
  PROCESSING_STATES = %w[unqueued queued processing] + FINISHED_STATES

  attr_accessor :paths # a virtual attribute to then use for creating entries

  belongs_to :user
  belongs_to :site
  has_many :entries, class_name: "MappingsBatchEntry", dependent: :delete_all

  validates :user, presence: true
  validates :site, presence: true
  validates :state, inclusion: { in: PROCESSING_STATES }

  scope :reportable, -> { where(seen_outcome: false).where("state != 'unqueued'") }

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
    state == "succeeded"
  end

  def failed?
    state == "failed"
  end

  def process
    with_state_tracking do
      entries.each do |entry|
        mapping = site.mappings.where(path: entry.path).first_or_initialize

        next if !update_existing && mapping.persisted?

        mapping.path = entry.path
        mapping.type = entry.type
        mapping.new_url = entry.new_url
        mapping.archive_url = entry.archive_url
        mapping.tag_list = [mapping.tag_list, tag_list].join(",")
        mapping.save!

        entry.update_column(:processed, true)
      end
    end
  end

  def with_state_tracking
    update_column(:state, "processing")
    yield
    update_column(:state, "succeeded")
  rescue StandardError
    update_column(:state, "failed")
    raise
  end
end
