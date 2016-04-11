module Adminable
  class Resource
    attr_reader :name, :model
    attr_writer :attributes

    def initialize(name)
      @name = name
      @model = name.classify.constantize
    end

    def route
      @route ||= @model.name.underscore.pluralize.tr('/', '_')
    end

    def includes
      @includes ||= if attributes.associations.present?
                      attributes.associations.map(&:name)
                    else
                      false
                    end
    end

    def attributes
      @attributes ||= Adminable::Attributes::Collection.new(@model)
    end
  end
end
