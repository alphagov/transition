desc "Change an organisation slug (DANGER!).\n

This rake task changes an organisation slug in the transition database.

It performs the following steps:
- changes whitehall_slug field of any affected organisation
- changes organisation_slug of users

NOTE:

When changing an organisation slug in transition, you should also modify any
site configuration files in the transition-config repo accordingly. The
transition-config repo is deployed automatically every hour during working
hours so you should plan carefully to ensure that the deployment of the
updated transition-config fits in with the running of this script.

Suggested process is therefore:

- make a pull request against transition-config to amend the sites
- make sure it's been reviewed and ready to merge
- run this rake task
- merge PR
- deploy transition-config

It is one part of an inter-related set of steps which must be carefully
coordinated.

For reference:

https://github.com/alphagov/wiki/wiki/Changing-GOV.UK-URLs#changing-an-organisations-slug"

task :change_organisation_slug, [:old_slug, :new_slug] => :environment do |_task, args|
  logger = Logger.new(STDOUT)

  if args[:old_slug].blank? || args[:new_slug].blank?
    logger.error("Please specify [old_slug,new_slug]")
    exit(1)
  end

  slug_changer = Transition::OrganisationSlugChanger.new(
    args[:old_slug],
    args[:new_slug],
    logger: logger
  )

  if !slug_changer.call
    exit(1)
  end
end
