module KissRestClient
  class ConnectionError < StandardError
      attr_reader :response

      def initialize(response, message = nil)
          @response = response
          @message  = message
      end

      def to_s
          message = ""
          message << "  Response code = #{response.code}." if response.respond_to?(:code)
          message << "  Response message = #{response.message}." if response.respond_to?(:message)

          if response.code < 500 && response.parsed_response.has_key?("errors")
            message << "  Response api message = #{response.parsed_response['errors']}"
          end

          message
      end
  end

  # Raised when a Timeout::Error occurs.
  class TimeoutError < ConnectionError
      def initialize(message)
          @message = message
      end
      def to_s
          @message
      end
  end

  # 3xx Redirection
  class Redirection < ConnectionError
      def to_s
          response['Location'] ? "#{super} => #{response['Location']}" : super
      end
  end

  # 4xx Client Error
  class ClientError < ConnectionError
  end

  # 400 Bad Request
  class BadRequest < ClientError
  end

  # 401 Unauthorized
  class UnauthorizedAccess < ClientError
  end

  # 403 Forbidden
  class ForbiddenAccess < ClientError
  end

  # 404 Not Found
  class ResourceNotFound < ClientError
  end

  # 409 Conflict
  class ResourceConflict < ClientError
  end

  # 422 Unprocessable Entity
  class ResourceInvalid < ClientError
  end

  # 5xx Server Error
  class ServerError < ConnectionError
  end

  # 405 Method Not Allowed
  class MethodNotAllowed < ClientError
      def allowed_methods
          @response['Allow'].split(',').map { |verb| verb.strip.downcase.to_sym }
      end
  end

end