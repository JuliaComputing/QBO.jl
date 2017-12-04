function request(api::API, request_method, endpoint;
            auth = AnonymousAuth(), handle_error = true,
            headers = Dict(), params = Dict(), allow_redirects = true,
            query = Dict())
    authenticate_headers!(headers, auth)
    headers["Accept"] = "application/json"
    api_endpoint = api_uri(api, endpoint)
    if request_method == Requests.get
        params["minorversion"] = "4"
        r = request_method(api_endpoint; headers = headers, query = params, allow_redirects = allow_redirects)
    else
        query["minorversion"] = 4
        r = request_method(api_endpoint; headers = headers, query = query,
                                            json = params, allow_redirects = allow_redirects)
    end
    handle_error && handle_response_error(r)
    return r
end

hget(api::API, endpoint; options...) = request(api, Requests.get, endpoint; options...)
post(api::API, endpoint; options...) = request(api, Requests.post, endpoint; options...)


##################
# Error Handling #
##################

function handle_response_error(r::HttpCommon.Response)
    if r.status >= 400
        dj = Requests.json(r)
        # Seem like qbo isn't consistent about this
        data = haskey(dj, "Fault") ? dj["Fault"] : dj["fault"]
        message = "Error found in QBO reponse:\n"*
                    "\tStatus Code: $(r.status)\n"
        for error in (haskey(data, "Error") ? data["Error"] : data["error"])
            message *= """
            \tMessage: $(strip(haskey(error, "Message") ? error["Message"] : error["message"]))\n
            \tDetail: $(strip(haskey(error, "Detail") ? error["Detail"] : error["detail"]))\n
            """
        end
        error(message)
    end
end