# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::BackfillDastSiteValidationsProjectId,
  feature_category: :dynamic_application_security_testing,
  schema: 20240607105701 do
  include_examples 'desired sharding key backfill job' do
    let(:batch_table) { :dast_site_validations }
    let(:backfill_column) { :project_id }
    let(:backfill_via_table) { :dast_site_tokens }
    let(:backfill_via_column) { :project_id }
    let(:backfill_via_foreign_key) { :dast_site_token_id }
  end
end
