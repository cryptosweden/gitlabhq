# frozen_string_literal: true

class AddPackagesConanMetadataProjectIdTrigger < Gitlab::Database::Migration[2.2]
  milestone '17.2'

  def up
    install_sharding_key_assignment_trigger(
      table: :packages_conan_metadata,
      sharding_key: :project_id,
      parent_table: :packages_packages,
      parent_sharding_key: :project_id,
      foreign_key: :package_id
    )
  end

  def down
    remove_sharding_key_assignment_trigger(
      table: :packages_conan_metadata,
      sharding_key: :project_id,
      parent_table: :packages_packages,
      parent_sharding_key: :project_id,
      foreign_key: :package_id
    )
  end
end
