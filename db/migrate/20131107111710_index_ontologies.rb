class IndexOntologies < ActiveRecord::Migration
  def change
    change_table :ontologies do |t|
      t.index :name
    end
    change_table :entities do |t|
      t.index :text
    end
  end
end
