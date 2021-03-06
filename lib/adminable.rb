require 'adminable/engine'
require 'adminable/configuration'
require 'adminable/errors'

require 'adminable/resource'
require 'adminable/resource_collector'

require 'adminable/presenters/helpers'
require 'adminable/presenters/entry'
require 'adminable/presenters/entries'

require 'adminable/decorators/fields'

require 'adminable/field_collector'

require 'adminable/fields/base'
require 'adminable/fields/belongs_to'
require 'adminable/fields/boolean'
require 'adminable/fields/date'
require 'adminable/fields/datetime'
require 'adminable/fields/decimal'
require 'adminable/fields/float'
require 'adminable/fields/has_many'
require 'adminable/fields/has_one'
require 'adminable/fields/integer'
require 'adminable/fields/string'
require 'adminable/fields/text'
require 'adminable/fields/time'
require 'adminable/fields/timestamp'

require 'haml-rails'
require 'sass-rails'
require 'jquery-rails'
require 'bootstrap'
require 'rails-assets-tether'
require 'kaminari'
require 'ransack'

module Adminable
  def self.resources
    Adminable::ResourceCollector.new(
      Adminable::Configuration.resources_paths
    ).resources
  end
end
