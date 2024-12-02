require_relative 'globals'
require_relative 'exit_helper'

module Dim
  class Consistency
    def initialize(loader)
      @loader = loader
    end

    def cyclic_check(ref, previous_ref, checked_ids = {}, list = [])
      return if checked_ids[ref.id]

      # Circular dependency can occur only on same category level
      return if previous_ref && (ref.category_level != previous_ref.category_level)

      if list.include?(ref.id)
        Dim::ExitHelper.exit(
          code: 1,
          filename: ref.filename,
          msg: "\"#{ref.id}\" is cyclically referenced: #{list.join(' -> ')} -> #{ref.id}"
        )
      end

      list << ref.id

      ref.existingRefs.each do |ref_id|
        cyclic_check(@loader.requirements[ref_id], ref, checked_ids, list)
      end

      list.pop

      # Any value other than nil and false will work, as this is being used to check
      # boolean condition on line#11
      checked_ids[ref.id] = 1 if list.empty?
    end
    private :cyclic_check

    def insert_default_values(req)
      req.all_attributes.each do |key, config|
        next if req.data.key?(key)

        req.data[key] = config[:default]
      end
    end

    def insert_property_file_definitions(ref)
      @loader.property_table.fetch(ref.document, {}).each do |attr, value|
        ref.data[attr] = value if ref.data[attr].nil?
      end
    end

    def calculate_verification_methods(ref)
      return unless ref.data['verification_methods'].nil?

      tags = ref.data['tags'].cleanArray

      ref.data['verification_methods'] = if ref.data['type'] != 'requirement' || tags.include?('process')
                                           'none'
                                         elsif ref.category == 'input' || ref.category == 'unspecified'
                                           'none'
                                         elsif ref.category == 'module'
                                           'off_target'
                                         elsif tags.include?('tool')
                                           'off_target'
                                         else
                                           'on_target'
                                         end
    end

    def calculate_review_status(ref)
      return unless ref.data['review_status'].nil?

      ref.data['review_status'] = if ref.category == 'input' || ref.category == 'unspecified'
                                    'not_reviewed'
                                  else
                                    'accepted'
                                  end
    end

    def clean_comma_separated(ref)
      %w[tags developer tester refs verification_methods].each do |var|
        ref.data[var] = ref.data[var].cleanString
      end
    end

    def calculate_developer_tester(ref)
      %w[developer tester].each do |t|
        next unless ref.data[t].nil?

        ref.data[t] = if ref.data['type'] != 'requirement'
                        ''
                      elsif ref.data['tags'].cleanArray.include?('process') && t == 'tester'
                        ''
                      elsif ref.category == 'input' || ref.category == 'unspecified'
                        ''
                      else
                        ref.origin
                      end
      end
    end

    def calculate_status(ref)
      return unless ref.data['status'].nil?

      ref.data['status'] = %w[requirement information].include?(ref.data['type']) ? 'draft' : 'valid'
    end

    def check(allow_missing:)
      requirements_by_module = {}
      @loader.module_data.keys.each { |um| requirements_by_module[um] = [] }
      @loader.requirements.each { |_id, r| requirements_by_module[r.document] << r }

      @loader.requirements.each do |_id, r|
        insert_property_file_definitions(r)
        insert_default_values(r)
        calculate_verification_methods(r)
        calculate_review_status(r)
        calculate_developer_tester(r)
        calculate_status(r)
      end

      @loader.requirements.each do |_id, r|
        clean_comma_separated(r)
      end

      @loader.requirements.each do |id, r|
        r.data['refs'].cleanArray.each do |ref|
          if !@loader.requirements.has_key?(ref)
            unless allow_missing
              Dim::ExitHelper.exit(
                code: 1,
                filename: r.filename,
                msg: "\"#{id}\" refers to non-existing \"#{ref}\""
              )
            end
          else
            # Generate upstream and downstream refs based on category level
            if @loader.requirements[id].category_level <= @loader.requirements[ref].category_level
              @loader.requirements[id].downstreamRefs |= [ref]
              @loader.requirements[ref].upstreamRefs |= [id]
            else
              @loader.requirements[id].upstreamRefs |= [ref]
              @loader.requirements[ref].downstreamRefs |= [id]
            end
            @loader.requirements[ref].backwardRefs << id
            r.existingRefs << ref
          end
        end
      end

      @checked_ids = {}
      @loader.requirements.each do |_id, r|
        cyclic_check(r, nil, @checked_ids)
      end
    end
  end
end
