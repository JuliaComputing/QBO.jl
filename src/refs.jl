struct QboRef{Obj}
    value::Int
end
Base.convert(::Type{QboRef{Obj}}, x::Obj) where {Obj} = QboRef{Obj}(x.Id)
Base.convert(::Type{Maybe{QboRef{Obj}}}, x::Obj) where {Obj} = QboRef{Obj}(x.Id)
Base.convert(::Type{Optional{QboRef{Obj}}}, x::Obj) where {Obj} = QboRef{Obj}(x.Id)
Base.convert(::Type{Optional{QboRef{<:Any}}}, x::Missing) = missing

from_json(::Type{QboRef{T}}, data) where {T} = QboRef{T}(parse(Int, data["value"]))
from_json(::Type{QboRef{<:QBObject}}, data) = from_json(QboRef{key_to_type(data["type"])}, data)

function to_json(::Type{QboRef{<:QBObject}}, obj::QBObject)
    Dict(
        "type"=>String(typeof(obj).name.name),
        "value"=>obj.value
    )
end
to_json(::Type, obj) = to_json(obj)

function to_json(data::QboRef)
    Dict("value"=>data.value)
end
