__precompile__()
module QBO

    using HttpCommon
    using Requests
    using JSON
    using AbstractTrees
    using FixedPointDecimals
    using Missings
    using Base.Meta

    abstract type QBObject; end

    export Line, Purchase

    # Missing => May have a value, but we don't know what it is
    # Void => Definitely no value there
    const Maybe{T} = Union{T, Missing}
    const Optional{T} = Union{T, Missing, Void}

    const Decimal = FixedDecimal{Int64, 2}

    include("utils.jl")
    include("refs.jl")
    include("mangling.jl")
    include("types.jl")
    include("auth.jl")
    include("request.jl")
    include("api.jl")
    include("query.jl")

end # module