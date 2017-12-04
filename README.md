# QBO - Integrate with Intuit QuickBooksOnline

[![Build Status](https://travis-ci.org/JuliaComputing/QBO.jl.svg?branch=master)](https://travis-ci.org/JuliaComputing/QBO.jl)

[![codecov.io](http://codecov.io/github/JuliaComputing/QBO.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaComputing/QBO.jl?branch=master)

# Installation

```
Pkg.checkout("JSON","kf/customfloat")
Pkg.clone("github.com/JuliaComputing/QBO.jl")
```

Pull requests are welcome. However, feature development and maintenance is done on an
as-needed basis.

# Overview
## Authentication
For now, this package expects you to give it an OAuth2 code you obtained externally.
The easiest way to do so is to create an Intuit Developer account and use the
[OAuth Playground](https://developer.intuit.com/v2/ui#/playground) to obtain the
OAuth ID (The long string starting with `ey` you obtain in step 3). For scopes you should
select "Accounting", which is the only API supported at the moment. You will then be prompted
to log in with QBO.

```
using QBO
auth = QBO.OAuth2("ey...")
```

## API
The correct place to start is probably by performing a query. QBO supports a pseudo-SQL
interface to query its data store, e.g.

```
QBO.query(c, "select * from purchase Order By Metadata.LastUpdatedTime"; auth=auth)[1]
```

You can create new objects by passing them to `QBO.create` and delete objects by passing
them to `QBO.delete`.