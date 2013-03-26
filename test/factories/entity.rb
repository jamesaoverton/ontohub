FactoryGirl.define do
  sequence :entity_text do |n|
    "http://host/ontology/#{n}"
  end
  
  sequence :entity_kind do |n|
    "Kind#{n}"
  end

  sequence :entity_owl2_text do |n|
    "Class <http://example.com/resource##{n}>"
  end

  sequence :entity_owl2_name do |n|
    "<http://example.com/resource##{n}>"
  end
  
  factory :entity do
    association :ontology
    text { FactoryGirl.generate :entity_text }
    kind { FactoryGirl.generate :entity_kind }
    name { Faker::Name.name }

    factory :entity_owl2 do
      text { FactoryGirl.generate :entity_owl2_text }
      name { FactoryGirl.generate :entity_owl2_name }
    end
  end
end
