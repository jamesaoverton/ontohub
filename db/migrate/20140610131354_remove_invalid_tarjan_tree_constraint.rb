class RemoveInvalidTarjanTreeConstraint < ActiveRecord::Migration
  def up
    change_table :entity_groups do |t|
      t.remove_index [:ontology_id, :name]
    end
  end

  def down

  end
end
