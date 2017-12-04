function strip_maybe(T)
    T === Missing && return Union{}
    !isa(T, Union) && return T
    return Union{strip_maybe(T.a), strip_maybe(T.b)}
end

optional_eltype(::Type{Union{T, Void}}) where {T} = T
optional_eltype(_) = Union{}

macro from_json(T, renamings)
    syms = Symbol[]
    body = Expr[]
    for (N,fT) in zip(fieldnames(T), T.types)
        sym = gensym()
        push!(syms, sym)
        name = string(N)
        if haskey(renamings, N)
            val = renamings[N]
            if isa(val, String)
                name = val
            else
                @assert isa(val, Expr)
                push!(body, :($sym = $val))
                continue
            end
        end
        sfT = strip_maybe(fT)
        oeT = optional_eltype(sfT)
        if oeT !== Union{}
            sfT = oeT
        end
        if sfT <: QboRef
            name *= "Ref"
            op = :($sym = from_json($sfT, data[$(name)]))
        elseif sfT <: Vector
            op = :($sym = map(x->from_json($(eltype(sfT)), x),data[$(name)]))
        else
            op = :($sym = from_json($sfT, data[$(name)]))
        end
        if oeT !== Union{}
            push!(body, quote
                if haskey(data, $(name))
                    $op
                else
                    $sym = nothing
                end
            end)
        else
            push!(body, op)
        end
    end
    esc(quote
        $(body...)
        $T($(syms...))
    end)
end


macro to_json(T, renamings)
    body = Expr[:(ret = Dict{String, Any}())]
    for (N,fT) in zip(fieldnames(T), T.types)
        name = string(N)
        if haskey(renamings, N)
            val = renamings[N]
            if isa(val, String)
                name = val
            else
                @assert isa(val, Expr)
                push!(body, val)
                continue
            end
        end
        sfT = strip_maybe(fT)
        oeT = optional_eltype(sfT)
        if oeT !== Union{}
            sfT = oeT
        end
        if sfT <: QboRef
            name *= "Ref"
            op = :(ret[$name] = to_json($sfT, getfield(data, $(quot(N)))))
        elseif sfT <: Vector
            op = :(ret[$name] = map(to_json,getfield(data, $(quot(N)))))
        else
            op = :(ret[$name] = to_json(getfield(data, $(quot(N)))))
        end
        push!(body, quote
            if !ismissing(getfield(data, $(quot(N)))) && getfield(data, $(quot(N))) !== nothing
                $op
            end
        end)
    end
    a = esc(quote
        $(body...)
        ret
    end)
end

from_json(::Type{Int}, s::String) = parse(Int, s)
from_json(::Type{String}, s::String) = s
from_json(::Type{Date}, s::String) = Date(s)
from_json(::Type{Decimal}, d::Decimal) = d
from_json(::Type{Bool}, b::Bool) = b

to_json(s::String) = s
to_json(d::Date) = repr(d)
to_json(d::Decimal) = d