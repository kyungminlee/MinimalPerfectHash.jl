# MinimalPerfectHash

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kyungminlee.github.io/MinimalPerfectHash.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kyungminlee.github.io/MinimalPerfectHash.jl/dev)

[![Build](https://github.com/kyungminlee/MinimalPerfectHash.jl/workflows/Build/badge.svg)](https://github.com/kyungminlee/MinimalPerfectHash.jl/actions?query=workflow%3ABuild)

[![Codecov](https://codecov.io/gh/kyungminlee/MinimalPerfectHash.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kyungminlee/MinimalPerfectHash.jl)

## Usage

```julia-repl
julia> using MinimalPerfectHash

julia> chd = CHD("elephant"=>10, "giraffe"=>17)
CHD{String,Int64} with 2 entries:
  "elephant" => 10
  "giraffe"  => 17

julia> chd["elephant"]
10
```