# frozen_string_literal: true

module Flatirons
  module Saas
    module Concerns
      #
      # Soft Delete Concern
      #
      module SoftDeletable
        extend ActiveSupport::Concern

        included do
          default_scope { where(deleted_at: nil) }
          scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
          scope :with_deleted, -> { unscope(where: :deleted_at) }
        end

        def self.included(klazz)
          klazz.extend Callbacks
        end

        module Load
          def soft_deletable?
            included_modules.include?(Flatirons::Saas::Concerns::SoftDeletable)
          end

          def soft_deletable
            return if soft_deletable?

            include Flatirons::Saas::Concerns::SoftDeletable
          end
        end

        module Callbacks
          def self.extended(klazz)
            klazz.define_callbacks :soft_restore
            klazz.define_singleton_method('before_soft_restore') do |*args, &block|
              set_callback(:soft_restore, :before, *args, &block)
            end
            klazz.define_singleton_method('around_soft_restore') do |*args, &block|
              set_callback(:soft_restore, :around, *args, &block)
            end
            klazz.define_singleton_method('after_soft_restore') do |*args, &block|
              set_callback(:soft_restore, :after, *args, &block)
            end

            klazz.define_callbacks :soft_destroy
            klazz.define_singleton_method('before_soft_destroy') do |*args, &block|
              set_callback(:soft_destroy, :before, *args, &block)
            end
            klazz.define_singleton_method('around_soft_destroy') do |*args, &block|
              set_callback(:soft_destroy, :around, *args, &block)
            end
            klazz.define_singleton_method('after_soft_destroy') do |*args, &block|
              set_callback(:soft_destroy, :after, *args, &block)
            end
          end
        end

        #
        # Soft Destroy
        #
        # @param [Boolean] recursive delete related models
        #
        # @return [Self]
        #
        def soft_destroy(recursive: true)
          result = transaction do
            run_callbacks :soft_destroy do
              destroy_associated_records if recursive
              soft_destroy_model
            end
          end
          result ? self : false
        end

        #
        # Soft Restore
        #
        # @param [Boolean] recursive restore related models
        #
        # @return [Self]
        #
        def soft_restore(recursive: true)
          result = transaction do
            run_callbacks :soft_restore do
              restore_associated_records if recursive
              soft_restore_model
            end
          end
          result ? self : false
        end

        private

        #
        # Soft Destroy Model
        #
        # @return [Boolean]
        #
        def soft_destroy_model
          update_column(:deleted_at, Time.zone.now) if has_attribute? :deleted_at # rubocop:disable Rails/SkipsModelValidations
        end

        #
        # Soft Restore Model
        #
        # @return [Boolean]
        #
        def soft_restore_model
          update_column(:deleted_at, nil) if has_attribute? :deleted_at # rubocop:disable Rails/SkipsModelValidations
        end

        def resolve_has_one_association(association)
          association_class_name = association.options[:class_name].presence || association.name.to_s.camelize
          association_foreign_key = association.options[:foreign_key].presence || "#{self.class.name.to_s.underscore}_id"
          Object.const_get(association_class_name).where("#{association_foreign_key} = ?", id)
        end

        def dependent_destroy_associations
          self.class.reflect_on_all_associations.select do |association|
            association.options[:dependent] == :destroy
          end
        end

        def restore_associated_records
          dependent_destroy_associations.each { |association| restore_assiciation(association) }
        end

        def restore_assiciation(association)
          association_data = send(association.name)

          unless association_data.nil?
            if association.collection?
              association_data.only_deleted.each do  |record|
                record.soft_restore(recursive: true)
              end
            else
              association_data.soft_restore(recursive: true)
            end
          end
          return unless association_data.nil? && association.macro.to_s == 'has_one'

          resolve_has_one_association(association).try(:soft_restore)
        end

        def destroy_associated_records
          dependent_destroy_associations.each { |association| destroy_assiciation(association) }
        end

        def destroy_assiciation(association)
          association_data = send(association.name)

          unless association_data.nil?
            if association.collection?
              association_data.each(&:soft_destroy)
            else
              association_data.soft_destroy
            end
          end
          return unless association_data.nil? && association.macro.to_s == 'has_one'

          resolve_has_one_association(association).try(:soft_destroy)
        end
      end
    end
  end
end
