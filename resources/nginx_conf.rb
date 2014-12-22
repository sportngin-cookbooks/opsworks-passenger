actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :source, :kind_of => String, :required => true
attribute :variables, :kind_of => [ Hash, NilClass ]