module KissRestClient
  module HttpClient
    module ClassMethods
      def get(**options)
        request(:get, options)
      end

      def post(**options)
        request(:post, options)
      end

      def put(**options)
        request(:put, options)
      end

      def patch(**options)
        request(:patch, options)
      end

      def delete(**options)
        request(:delete, options)
      end

      private

      def request(method, url: nil, body:{}, query: {}, headers: {}, **options)
        path = prepare_url(url)

        cached_response = read_cache(path)
        if cached_response && cached_response["etag"]
            headers["If-None-Match"] = cached_response["etag"]
        end

        call_options = prepare_call_options(body, query, headers, options)
        response = HTTParty.send method, path, call_options

        write_cache(path, response)

        handle_response response, cached_response
      end

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

      def handle_response(response, cached_response)
            case response.code.to_i
            when 301, 302, 303, 307
              raise(KissRestClient::Redirection.new(response))
            when 304
              cached_response["parsed_response"]
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