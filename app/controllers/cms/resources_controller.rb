module Cms
  class ResourcesController < ApplicationController
    before_action :set_resource
    before_action :set_entry, only: [:edit, :update, :destroy]

    before_action do
      append_view_path Cms::Engine.root.join('app/views/cms', controller_name)
      append_view_path Cms::Engine.root.join('app/views/cms/resources')
    end

    def index
      @entries = @resource.model.includes(*@resource.includes).all
                          .page(params[:page]).per(25)
    end

    def new
      @entry = @resource.model.new
    end

    def edit
    end

    def create
      @entry = @resource.model.new(resource_params)

      if @entry.save
        redirect_to polymorphic_path(@resource.model),
                    notice: t(
                      'cms.resources.created',
                      resource: @resource.model.model_name.human
                    )
      else
        flash.now[:alert] = @entry.errors.full_messages
        render :new
      end
    end

    def update
      if @entry.update(resource_params)
        redirect_to polymorphic_path(@resource.model),
                    notice: t(
                      'cms.resources.updated',
                      resource: @resource.model.model_name.human
                    )
      else
        flash.now[:alert] = @entry.errors.full_messages
        render :edit
      end
    end

    def destroy
      @entry.destroy

      redirect_to polymorphic_path(@resource.model),
                  notice: t(
                    'cms.resources.deleted',
                    resource: @resource.model.model_name.human
                  )
    end

    private

      def set_resource
        @resource = Cms::Configuration.find_resource(resource_model)

        @resource.index_attributes = index_attributes
        @resource.form_attributes = form_attributes
      end

      def set_entry
        @entry = @resource.model.find(params[:id])
      end

      def index_attributes
        @resource.index_attributes
      end

      def form_attributes
        @resource.form_attributes
      end

      def resource_model
        controller_path.sub(%r{^cms/}, '')
      end

      def resource_params
        params.require(@resource.model.model_name.param_key).permit(
          *@resource.form_attributes.values.map(&:strong_parameter)
        )
      end
  end
end
