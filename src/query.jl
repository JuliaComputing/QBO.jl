@api_default function raw_query(api::API, company::Company, q; options...)
    res = hget(api, "/company/$(company.Id)/query", params=Dict("query"=>q); options...)
    Tree(JSON.parse(String(res.data); floattype=Decimal))
end

@api_default function query(api::API, company::Company, q; options...)
    r = raw_query(api, company, q; options...).x
    [map(x->from_json(key_to_type(kv[1]), x), kv[2]) for kv in filter(
        (k,_)->k ∉ ("startPosition", "maxResults", "totalCount"), r["QueryResponse"])]
end
