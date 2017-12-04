macro make_constructor(T)
    initial_values = []
    for (N,fT) in zip(fieldnames(T), T.types)
        push!(initial_values, if fT <: Vector
            :($fT())
        else
            :(missing)
        end)
    end

    esc(quote
        $(T.name.name)() = $(T.name.name)($(initial_values...))
    end)
end

macro make_default_methods(T, renamings=Dict())
    esc(quote
        @make_constructor $T
        to_json(data::$T) = @to_json $T $renamings
        from_json(::Type{$T}, data) = @from_json $T $renamings
    end)
end