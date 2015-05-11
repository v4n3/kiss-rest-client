module KissRestClient
  module HttpClient
    module ClassMethods
      def get(url: nil, body: {}, query: {}, headers: {}, **options)
        handle_response HTTParty.get(prepare_url(url), prepare_call_options(body, query, headers, options))
      end

      def post(url: nil, body: {}, query: {}, headers: {}, **options)
        handle_response HTTParty.post(prepare_url(url), prepare_call_options(body, query, headers, options))
      end

      def put(url: nil, body: {}, query: {}, headers: {}, **options)
        handle_response HTTParty.put(prepare_url(url), prepare_call_options(body, query, headers, options))
      end

      def patch(url: nil, body: {}, query: {}, headers: {}, **options)
        handle_response HTTParty.patch(prepare_url(url), prepare_call_options(body, query, headers, options))
      end

      def delete(url: nil, body: {}, query: {}, headers: {}, **options)
        handle_response HTTParty.delete(prepare_url(url), prepare_call_options(body, query, headers, options))
      end

      private

      def prepare_call_options(body, query, headers, options)
        # Prepare http request params
        call_params = {}
        call_params[:query] = query if !query.nil? && !query.empty?
        call_params[:body] = body if !body.nil? && !body.empty?
        call_params[:headers] = prepare_call_headers(headers)

        call_params[:logger] = KissRestClient::Logger
        KissRestClient::Logger.debug("[HTTParty] request params: #{call_params.inspect}");

        call_params
      end

      def prepare_call_headers(option_headers)
        # merge the default ones with method specified ones
        option_headers = headers.merge(option_headers)
      end

      def prepare_url(url=nil)
        full_url = base_url
        full_url += '/' + collection_name if collection_name
        full_url += '/' + url if url
      end

      def handle_response(response)
            case response.code.to_i
            when 301, 302, 303, 307
                raise(KissRestClient::Redirection.new(response))
            when 200...400
                response.parsed_response
            when 400
                raise(KissRestClient::BadRequest.new(response))
            when 401
                raise(KissRestClient::UnauthorizedAccess.new(response))
            when 403
                raise(KissRestClient::ForbiddenAccess.new(response))
            when 404
                raise(KissRestClient::ResourceNotFound.new(response))
            when 405
                raise(KissRestClient::MethodNotAllowed.new(response))
            when 409
                raise(KissRestClient::ResourceConflict.new(response))
            when 422
                raise(KissRestClient::ResourceInvalid.new(response))
            when 401...500
                raise(KissRestClient::ClientError.new(response))
            when 500...600
                raise(KissRestClient::ServerError.new(response))
            else
                raise(KissRestClient::ConnectionError.new(response, "Unknown response code: #{response.code}"))
            end
        end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end