module Cms
  class ResourcesController < ApplicationController
    before_action :set_resource
    before_action :set_attributes_for_index, only: :index
    before_action :set_attributes_for_form, only: [:new, :edit, :create, :update]
    before_action :set_entry, only: [:edit, :update, :destroy]

    before_action do
      append_view_path File.join('app/views/cms', controller_name)
      append_view_path Cms::Engine.root.join('app/views/cms/resources')
    end

    def index
      @entries = @resource.all
    end

    def new
      @entry = @resource.new
    end

    def edit
    end

    def create
      @entry = @resource.new(resource_params)

      if @entry.save
        redirect_to polymorphic_path(@resource), notice: 'Successfully Created.'
      else
        flash.now[:alert] = @entry.errors.full_messages
        render :new
      end
    end

    def update
      if @entry.update(resource_params)
        redirect_to polymorphic_path(@resource), notice: 'Successfully Updated.'
      else
        flash.now[:alert] = @entry.errors.full_messages
        render :edit
      end
    end

    def destroy
      @entry.destroy

      redirect_to polymorphic_path(@resource), notice: 'Successfully Destroyed.'
    end

    private

      def set_resource
        @resource = resource_model
      end

      def set_attributes_for_index
        @attributes_for_index = attributes_for_index
      end

      def set_attributes_for_form
        @attributes_for_form = attributes_for_form
      end

      def set_entry
        @entry = @resource.find(params[:id])
      end

      def attributes_for_index
        self.class::attributes_for_index
      rescue NameError
        attributes.reject do |attribute|
          %w(created_at updated_at).include?(attribute.name)
        end
      end

      def attributes_for_form
        self.class::ATTRIBUTES_FOR_FORM
      rescue NameError
        attributes.reject do |attribute|
          %w(id created_at updated_at).include?(attribute.name)
        end
      end

      def resource_model
        self.class::RESOURCE_MODEL
      rescue NameError
        controller_name.classify.safe_constantize
      end

      def attributes
        @attributes = []

        @attributes += @resource.columns.reject do |attribute|
          attribute.name.match(/_id$/)
        end.map do |column|
          "cms/attribute/#{ column.type }".classify.constantize.new(column.name)
        end

        @attributes += @resource.reflect_on_all_associations(:belongs_to).map do |association|
          Cms::Attribute::BelongsTo.new(
            association.name,
            key: association.foreign_key,
            klass: association.klass
          )
        end

        @attributes += @resource.reflect_on_all_associations(:has_many).map do |association|
          Cms::Attribute::HasMany.new(
            association.name,
            key: association.foreign_key,
            klass: association.klass
          )
        end

        @attributes
      end

      def resource_params
        params.require(@resource.model_name.element).permit(*attributes_for_form.map(&:strong_parameter))
      end
  end
end
