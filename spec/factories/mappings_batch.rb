require "transition/history"

FactoryBot.define do
  factory :bulk_add_batch do
    type { "archive" }
    paths { ["/a", "/b"] }
    state { "unqueued" }

    association :site, strategy: :build
    association :user, strategy: :build
  end

  factory :import_batch do
    state { "unqueued" }

    raw_csv do
      <<-CSV.strip_heredoc
        /oldurl1
        /oldurl2
      CSV
    end

    association :site, strategy: :build
    association :user, strategy: :build
  end

  factory :large_import_batch, parent: :import_batch do
    raw_csv do
      <<-CSV.strip_heredoc
        /1
        /2
        /3
        /4
        /5
        /6
        /7
        /8
        /9
        /10
        /11
        /12
        /13
        /14
        /15
        /16
        /17
        /18
        /19
        /20
        /21
      CSV
    end
  end
end
