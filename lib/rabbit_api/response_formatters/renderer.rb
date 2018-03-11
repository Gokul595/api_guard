module RabbitApi
  module ResponseFormatters
    module Renderer
      def render_success(data: nil, message: nil)
        resp_data = { status: 'success' }
        resp_data[:message] = message if message
        resp_data[:data] = data if data

        render json: resp_data, status: 200
      end

      def render_error(status, options = {})
        data = { status: 'error' }
        data[:errors] = if options[:object]
                          options[:object].errors.full_messages
                        elsif options[:message]
                          options[:message].is_a?(Array) ? options[:message] : [options[:message]]
                        end

        render json: data, status: status
      end
    end
  end
end
