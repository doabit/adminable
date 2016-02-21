module Cms
  module Attribute
    class Base
      attr_accessor :name
      attr_reader :type, :key, :klass, :strong_parameter, :index_partial_path, :form_partial_path

      def initialize(name, options = {})
        @name = name
        @key = options[:key]
        @klass = options[:klass]
      end

      def type
        self.class.name.demodulize.underscore
      end

      def key
        @key || @name
      end

      def strong_parameter
        @key
      end

      def index_partial_path
        "index/#{ self.type }"
      end

      def form_partial_path
        "cms/resources/form/#{ self.type }"
      end
    end
  end
end