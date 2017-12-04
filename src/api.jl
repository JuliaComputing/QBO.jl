@api_default function delete(api::API, company::Company, p::Purchase; options...)
    post(api, "/company/$(company.Id)/purchase",
    query=Dict{Any,Any}(
        "operation" => "delete"
    ),
    params=Dict(
        "Id" => p.Id,
        "SyncToken" => p.SyncToken
    ); options...)
end

@api_default function create(api::API, company::Company, p::Purchase; options...)
    post(api, "/company/$(company.Id)/purchase",
    params=to_json(p); options...)
end