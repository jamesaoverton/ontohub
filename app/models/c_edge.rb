class CEdge < ActiveRecord::Base
  extend Dagnabit::Edge::Activation

  attr_accessible :parent_id, :child_id

  acts_as_edge
  connects 'CVertex'
end