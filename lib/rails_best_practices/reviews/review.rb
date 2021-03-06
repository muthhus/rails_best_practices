# encoding: utf-8
require 'rails_best_practices/core/check'
require 'rails_best_practices/core/error'

module RailsBestPractices
  module Reviews
    # A Review class that takes charge of reviewing one rails best practice.
    class Review < Core::Check
      # default url.
      def url
        "#"
      end
      # remember use count for the variable in the call or assign node.
      #
      # find the variable in the call or assign node,
      # then save it to as key in @variable_use_count hash, and add the call count (hash value).
      def remember_variable_use_count(node)
        variable_node = variable(node)
        if variable_node && "self" != variable_node.to_s
          variable_use_count[variable_node.to_s] ||= 0
          variable_use_count[variable_node.to_s] += 1
        end
      end

      # return @variable_use_count hash.
      def variable_use_count
        @variable_use_count ||= {}
      end

      # reset @variable_use_count hash.
      def reset_variable_use_count
        @variable_use_count = nil
      end

      # find variable in the call or field node.
      def variable(node)
        while [:call, :field, :method_add_arg, :method_add_block].include?(node.subject.sexp_type)
          node = node.subject
        end
        return if [:fcall, :hash].include?(node.subject.sexp_type)
        node.subject
      end

      # get the models from Prepares.
      #
      # @return [Array]
      def models
        @models ||= Prepares.models
      end

      # get the model associations from Prepares.
      #
      # @return [Hash]
      def model_associations
        @model_associations ||= Prepares.model_associations
      end

      # get the model attributes from Prepares.
      #
      # @return [Hash]
      def model_attributes
        @model_attributes ||= Prepares.model_attributes
      end
    end
  end
end
