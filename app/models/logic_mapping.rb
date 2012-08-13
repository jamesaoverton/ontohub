class LogicMapping < ActiveRecord::Base
  include Resourcable
  
  FAITHFULNESSES = %w( faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalised )
end