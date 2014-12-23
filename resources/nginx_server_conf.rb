actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :source, :kind_of => String, :required => true
attribute :scope, :kind_of => String, :equal_to => %w[shared http ssl], :default => 'shared'
attribute :variables, :kind_of => [ Hash, NilClass ]