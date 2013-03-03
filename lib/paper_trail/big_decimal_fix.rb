module ActiveSupport
    module CoreExtensions
      module BigDecimal
        module Conversions
          def encode_with(coder)
            string = to_s
            coder.represent_scalar(nil, YAML_MAPPING[string] || string)
          end
          # Backport this method if it doesn't exist
          unless method_defined?(:to_d)
            def to_d
              self
            end
          end
        end
      end
    end
  end
