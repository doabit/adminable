module Cms
  class Resource
    attr_accessor :model, :attributes, :index_attributes, :form_attributes

    def initialize(model)
      @model = if model.kind_of?(String)
        model.classify.constantize
      else
        model
      end
    end

    def route_name
      @route_name ||= @model.name.underscore.pluralize.tr('/', '_')
    end

    def route_path
      @route_path ||= @model.name.underscore.pluralize
    end

    def includes
      @includes ||= if association_attributes.present?
        association_attributes.map(&:name)
      else
        false
      end
    end

    def index_attributes
      @index_attributes ||= self.attributes
        .except(:created_at, :updated_at)
    end

    def form_attributes
      @form_attributes ||= self.attributes
        .except(:id, :created_at, :updated_at)
    end

    def attributes
      @attributes ||= Hash.new.tap do |attribute|
        columns_attributes.each do |column|
          attribute[column.name] = "cms/attribute/#{ column.type }"
            .classify.constantize.new(column.name)
        end

        belongs_to_attributes.each do |association|
          attribute[association.name] = Cms::Attribute::BelongsTo.new(
            association.name,
            association: association
          )
        end

        has_many_attributes.each do |association|
          attribute[association.name] = Cms::Attribute::HasMany.new(
            association.name,
            association: association
          )
        end
      end.symbolize_keys
    end

    private

      def columns_attributes
        @model.columns.reject{ |a| a.name.match(/_id$/) }
      end

      def belongs_to_attributes
        @model.reflect_on_all_associations(:belongs_to)
      end

      def has_many_attributes
        @model.reflect_on_all_associations(:has_many)
      end

      def association_attributes
        belongs_to_attributes.concat(has_many_attributes)
      end
  end
end
