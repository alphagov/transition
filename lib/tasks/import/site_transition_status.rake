require 'transition/import/site_transition_status'

namespace :import do
  desc 'Update transition_status on all sites from their hosts\' CNAMEs'
  task :site_transition_status => :environment do
    Transition::Import::SiteTransitionStatus.from_hosts!
  end
end
