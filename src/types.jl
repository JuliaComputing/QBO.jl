# Stubs - Can be used as references
struct Account <: QBObject end
struct ItemBasedExpenseLineDetail; end
struct Employee <: QBObject end
struct Vendor <: QBObject end
struct Customer <: QBObject end
struct Item <: QBObject end

struct Company <: QBObject
    Id::Maybe{Int}
end

from_json(::Type{ItemBasedExpenseLineDetail}, data) = ItemBasedExpenseLineDetail()

# Class
struct Class <: QBObject
    Id::Maybe{Int64}
    SyncToken::Maybe{Int64}
    Parent::Optional{QboRef{Class}}
    Name::Maybe{String}
    Active::Maybe{Bool}
end
@eval @make_default_methods $Class

# PaymentMethod
mutable struct PaymentMethod
    Id::Maybe{Int}
    SyncToken::Maybe{Int}
    Name::Maybe{String}
    Type::Maybe{String}
end
@eval @make_default_methods $PaymentMethod

### Purchases

struct AccountBasedExpenseLineDetail
    Account::QboRef{Account}
    Class::Optional{QboRef{Class}}
    BillableStatus::String
end
@eval @make_default_methods $AccountBasedExpenseLineDetail

const DetailType = Union{ItemBasedExpenseLineDetail,
                         AccountBasedExpenseLineDetail}

struct Line
    Id::Maybe{Int}
    Amount::Maybe{Decimal}
    Detail::DetailType
end

Line(Amount::Decimal, Detail::DetailType) = Line(missing, Amount, Detail)

@eval from_json(::Type{Line}, data) = @from_json $Line $(Dict(
    :Detail => quote
        if data["DetailType"] == "AccountBasedExpenseLineDetail"
            from_json(AccountBasedExpenseLineDetail,
                data["AccountBasedExpenseLineDetail"])
        elseif data["DetailType"] == "ItemBasedExpenseLineDetail"
            from_json(ItemBasedExpenseLineDetail,
                data["ItemBasedExpenseLineDetail"])
        end
    end
))

@eval to_json(data::Line) = @to_json $Line $(Dict(
    :Detail => quote
        if isa(data.Detail, AccountBasedExpenseLineDetail)
            ret["DetailType"] = "AccountBasedExpenseLineDetail"
            ret["AccountBasedExpenseLineDetail"] = to_json(data.Detail)
        elseif isa(data.Detail, ItemBasedExpenseLineDetail)
            ret["DetailType"] = "ItemBasedExpenseLineDetail"
            ret["ItemBasedExpenseLineDetail"] = to_json(data.Detail)
        end
    end
    ))

mutable struct Purchase <: QBObject
    Id::Maybe{Int}
    SyncToken::Maybe{Int}
    Account::Maybe{QboRef{Account}}
    PaymentMethod::Optional{QboRef{PaymentMethod}}
    PaymentType::Maybe{String}
    Entity::Maybe{QboRef{<:QBObject}}
    TxnDate::Maybe{Date}
    Lines::Vector{Line}
end

@eval @make_default_methods $Purchase $(Dict(
    :Lines => "Line"
))

# Type Mapping
function key_to_type(key::String)
    Dict{String, Type}(
        "Purchase" => Purchase,
        "Class" => Class,
        "Employee" => Employee,
        "PaymentMethod" => PaymentMethod
    )[key]
end