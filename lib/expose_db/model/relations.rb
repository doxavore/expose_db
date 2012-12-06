module ExposeDB
  module Relations
    def belongs_to(name, options = {})
      if options.key?(:class_name)
        class_name = options.fetch(:class_name).to_s
      else
        class_name = name.to_s.titleize
      end

      foreign_key = (options[:foreign_key] ||
                     "#{name.to_s.underscore}_id").to_sym

      define_method(name) do
        found = instance_variable_get(:"@#{name}")
        return found if found

        if id = send(foreign_key)
          found = self.class.resolve_relation_class(class_name).find(id)
          instance_variable_set(:"@#{name}", found)
        end
        found
      end
    end

    def has_many(plural_name, options = {})
      singular_name = plural_name.to_s.sub(/s\Z/, '')

      if options.key?(:class_name)
        class_name = options.fetch(:class_name).to_s
      else
        class_name = singular_name.titleize
      end

      primary_key = (options[:primary_key] || :id).to_sym

      foreign_key = (options[:foreign_key] ||
                     "#{singular_name.underscore}_id").to_sym

      define_method(plural_name) do
        found = instance_variable_get(:"@#{plural_name}")
        return found if found

        relation_class = self.class.resolve_relation_class(class_name)
        found = relation_class.filter("#{foreign_key} = ?", send(primary_key))
        instance_variable_set(:"@#{plural_name}", found)
        found
      end
    end

    def resolve_relation_class(class_name)
      resolved_relation_classes[class_name] ||= constantize_class_from_name(class_name)
    end

    def resolved_relation_classes
      @resolved_relation_classes ||= {}
    end

    # Selected from ActiveSupport
    def constantize_class_from_name(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end
  end
end
