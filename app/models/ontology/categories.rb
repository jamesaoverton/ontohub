module Ontology::Categories
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :categories
    attr_accessible :parent_id
  end


  def create_categories 
    if self.logic.name != 'OWL2' then
      raise Exception.new('Error: No OWL2')
    end
    classes = self.entities.select { |e| e.kind == 'Class' }
    subclasses = self.sentences.select { |e| e.text.include?('SubClassOf')}
    classes.each do |c|
      Category.create(:name => c.display_name || c.name)
    end

    subclasses.each do |s|
      c1,c2 = s.name.split('SubClassOf:').map do |c|
        c.scan(/.*#([A-Za-z0-9_-]*).*/)[0][0]
      end
      child = Category.find_by_name(c1)
      child.parent = Category_find_by_name(c2)
      child.save!
    end
  end

end
