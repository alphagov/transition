namespace :temp do
  desc "Change the organisations for a select group of formerly BEIS sites"
  task modify_beis_orgs: :environment do
    desnz_hosts = [
      "archive.bis.gov.uk",
      "blog.decc.gov.uk",
      "blogs.bis.gov.uk",
      "ceo.decc.gov.uk",
      "choices.bis.gov.uk",
      "chp.decc.gov.uk",
      "chpqa.decc.gov.uk",
      "consultations.bis.gov.uk",
      "conversation.bis.gov.uk",
      "corwm.decc.gov.uk",
      "digital.bis.gov.uk",
      "discuss.bis.gov.uk",
      "diversity.bis.gov.uk",
      "etl.decc.gov.uk",
      "forms.bis.gov.uk",
      "gdcashback.decc.gov.uk",
      "iacl.bis.gov.uk",
      "interactive.bis.gov.uk",
      "library.bis.gov.uk",
      "mrws.decc.gov.uk",
      "my2050.decc.gov.uk",
      "news.bis.gov.uk",
      "nlss.bis.gov.uk",
      "og.decc.gov.uk",
      "publications.bis.gov.uk",
      "publicsectorinnovation.bis.gov.uk",
      "rct.bis.gov.uk",
      "rdna-tool.bis.gov.uk",
      "renewableconsultation.bis.gov.uk",
      "restats.decc.gov.uk",
      "sandbox.bis.gov.uk",
      "search.bis.gov.uk",
      "stats.bis.gov.uk",
      "sts.bis.gov.uk",
      "talk.bis.gov.uk",
      "tools.decc.gov.uk",
      "vapp.bis.gov.uk",
      "www.beis.gov.uk",
      "www.berr.gov.uk",
      "www.bis.gov.uk",
      "www.decc.gov.uk",
      "www.dti.gov.uk",
      "www.mentorme.bis.gov.uk",
      "www.offshore-sea.org.uk",
      "www.simpleenergyadvice.org.uk",
    ]
    dsit_hosts = [
      "hsctoolkit.bis.gov.uk",
      "hsctraininggateway.bis.gov.uk",
      "scienceandsociety.bis.gov.uk",
      "www.aebc.gov.uk",
      "www.dius.gov.uk",
      "www.dsit.gov.uk",
      "www.sciencewise-erc.org.uk",
      "www.securityhealthcheck.bis.gov.uk",
      "www.sigmascan.org",
    ]

    desnz_sites = Site.all.select { |site| desnz_hosts.include?(site.default_host.hostname) }
    dsit_sites = Site.all.select { |site| dsit_hosts.include?(site.default_host.hostname) }

    dsit = Organisation.find_by(whitehall_slug: "department-for-science-innovation-and-technology")
    desnz = Organisation.find_by(whitehall_slug: "department-for-energy-security-and-net-zero")

    desnz_sites.each { |site| site.update(organisation_id: desnz.id) }
    dsit_sites.each { |site| site.update(organisation_id: dsit.id) }
  end
end
