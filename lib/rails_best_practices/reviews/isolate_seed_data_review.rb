# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Make sure not to insert data in migration, move them to seed file.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/20-isolating-seed-data.
    #
    # Implementation:
    #
    # Review process:
    #   1. check all assignment nodes,
    #   if the right value is a call node with message "new",
    #   then remember their left value as new variables.
    #
    #   2. check all call nodes,
    #   if the message is "create" or "create!",
    #   then it should be isolated to db seed.
    #   if the message is "save" or "save!",
    #   and the subject is included in new variables,
    #   then it should be isolated to db seed.
    class IsolateSeedDataReview < Review
      def url
        "http://rails-bestpractices.com/posts/20-isolating-seed-data"
      end

      def interesting_nodes
        [:call, :assign]
      end

      def interesting_files
        MIGRATION_FILES
      end

      def initialize
        super
        @new_variables = []
      end

      # check assignment node.
      #
      # if the right value of the node is a call node with "new" message,
      # then remember it as new variables.
      def start_assign(node)
        remember_new_variable(node)
      end

      # check the call node.
      #
      # if the message of the call node is "create" or "create!",
      # then you should isolate it to seed data.
      #
      # if the message of the call node is "save" or "save!",
      # and the subject of the call node is included in @new_variables,
      # then you should isolate it to seed data.
      def start_call(node)
        if ["create", "create!"].include? node.message.to_s
          add_error("isolate seed data")
        elsif ["save", "save!"].include? node.message.to_s
          add_error("isolate seed data") if new_record?(node)
        end
      end

      private
        # check assignment node,
        # if the right vavlue is a method_add_arg node with message "new",
        # then remember the left value as new variable.
        def remember_new_variable(node)
          right_value = node.right_value
          if :method_add_arg == right_value.sexp_type && "new" == right_value.message.to_s
            @new_variables << node.left_value.to_s
          end
        end

        # see if the subject of the call node is included in the @new_varaibles.
        def new_record?(node)
          @new_variables.include? node.subject.to_s
        end
    end
  end
end
