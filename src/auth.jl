"""
Represents the API to interact with, either an actual QBO instance, a sandbox,
or a mock API for testing purposes
"""
abstract type API end

struct WebAPI <: API
    oauth::HttpCommon.URI
    endpoint::HttpCommon.URI
end
api_uri(api::WebAPI, path) = HttpCommon.URI(api.endpoint, path = string(api.endpoint.path,path))

const DEFAULT_API = WebAPI(HttpCommon.URI("https://appcenter.intuit.com/connect/oauth2"),
                            HttpCommon.URI("https://sandbox-quickbooks.api.intuit.com/v3"))

using Base.Meta
"""
For a method taking an API argument, add a new method without the API argument
that just calls the method with DEFAULT_API.
"""
macro api_default(func)
    call = func.args[1]
    has_kwargs = isexpr(call.args[2], :parameters)
    newcall = Expr(:call, call.args[1], (has_kwargs ?
        [Expr(:parameters, Expr(:..., :kwargs)); call.args[4:end]] : call.args[3:end])...)
    argnames = map(has_kwargs ? call.args[4:end] : call.args[3:end]) do expr
        isexpr(expr, :kw) && (expr = expr.args[1])
        isexpr(expr, Symbol("::")) && return expr.args[1]
        @assert isa(expr, Symbol)
        return expr
    end
    esc(Expr(:toplevel, func,
        Expr(:function, newcall, Expr(:block,
            has_kwargs ? :($(call.args[1])(DEFAULT_API, $(argnames...); kwargs...)) :
                            :($(call.args[1])(DEFAULT_API, $(argnames...)))
        ))))
end

abstract type Authorization end
abstract type QBObject end

struct AuthCode <: Authorization
    code::String
    realm::Int
end

struct OAuth2 <: Authorization
    token::String
end

struct AnonymousAuth <: Authorization
end

function authenticate_headers!(headers, auth::OAuth2)
    headers["Authorization"] = "Bearer $(auth.token)"
    return headers
end
