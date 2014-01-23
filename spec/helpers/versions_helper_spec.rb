#encoding: utf-8
require 'spec_helper'

describe VersionsHelper do
  describe '#friendly_changeset_field' do
    specify { helper.friendly_changeset_field('http_status').should == 'Type' }
    specify { helper.friendly_changeset_field('archive_url').should == 'Alternative Archive URL' }
    specify { helper.friendly_changeset_field('miscellaneous').should == 'Miscellaneous' }
  end

  describe '#friendly_changeset_title' do
    specify { helper.friendly_changeset_title({'id' => 1}).should == 'Mapping created' }
    specify { helper.friendly_changeset_title({'archive_url' => 1}).should == 'Alternative Archive URL updated' }
    specify { helper.friendly_changeset_title({'miscellaneous' => 1}).should == 'Miscellaneous updated' }
    specify { helper.friendly_changeset_title({'archive_url' => 1, 'miscellaneous' => 1}).should == 'Multiple properties updated' }
    specify { helper.friendly_changeset_title({'http_status' => ['301']}).should == 'Switched mapping to an Archive' }
    specify { helper.friendly_changeset_title({'http_status' => ['410']}).should == 'Switched mapping to a Redirect' }
  end

  describe '#friendly_changeset_values' do
    specify { helper.friendly_changeset_values('misc', ['old', 'new']).should == 'old → new' }
    specify { helper.friendly_changeset_values('misc', ['', 'new']).should == '<blank> → new' }
    specify { helper.friendly_changeset_values('http_status', ['410', '301']).should == 'Archive → Redirect' }
    specify { helper.friendly_changeset_values('http_status', ['', '301']).should == '<blank> → Redirect' }
  end
end
