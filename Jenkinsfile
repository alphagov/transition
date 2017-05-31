#!/usr/bin/env groovy

REPOSITORY = 'transition'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  govuk.buildProject([
      beforeTest: { -> sh("bundle exec rake db:environment:set") }
  ])

  try {
    stage('Checkout') {
      checkout scm
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
      govuk.contentSchemaDependency()
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
      govuk.setEnvar("DISPLAY", ":99")
    }

    stage('Bundle') {
      govuk.bundleApp()
    }

    stage('Linting') {
      govuk.rubyLinter()
    }

    stage('Tests') {
      govuk.runRakeTask("db:reset")
      govuk.precompileAssets()
      govuk.runRakeTask("nolint")
      govuk.runRakeTask("check_for_bad_time_handling")
    }

    if (env.BRANCH_NAME == 'master') {
      stage('Push release tag') {
        govuk.pushTag(REPOSITORY, BRANCH_NAME, 'release_' + BUILD_NUMBER)
      }

      stage('Deploy to Integration') {
        govuk.deployIntegration(REPOSITORY, BRANCH_NAME, 'release', 'deploy')
      }
    }
  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
