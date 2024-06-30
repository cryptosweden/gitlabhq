# frozen_string_literal: true

class AddRelatedEpicLinksGroupIdTrigger < Gitlab::Database::Migration[2.2]
  milestone '17.1'

  def up
    install_sharding_key_assignment_trigger(
      table: :related_epic_links,
      sharding_key: :group_id,
      parent_table: :epics,
      parent_sharding_key: :group_id,
      foreign_key: :source_id
    )
  end

  def down
    remove_sharding_key_assignment_trigger(
      table: :related_epic_links,
      sharding_key: :group_id,
      parent_table: :epics,
      parent_sharding_key: :group_id,
      foreign_key: :source_id
    )
  end
end
