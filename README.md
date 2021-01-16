# MinimalPerfectHash

| **Documentation** | **Build Status** | **Code Coverage** |
|:-----------------:|:----------------:|:-----------------:|
| [![**STABLE**][docs-stable-img]][docs-stable-url] [![**DEV**][docs-dev-img]][docs-dev-url] | [![Build][githubaction-img]][githubaction-url] | [![Code Coverage][codecov-img]][codecov-url] |

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


[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://kyungminlee.org/MinimalPerfectHash.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: http://kyungminlee.org/MinimalPerfectHash.jl/dev

[githubaction-img]: https://github.com/kyungminlee/MinimalPerfectHash.jl/workflows/Build/badge.svg
[githubaction-url]: https://github.com/kyungminlee/MinimalPerfectHash.jl/actions?query=workflow%3ABuild

[codecov-img]: https://codecov.io/gh/kyungminlee/MinimalPerfectHash.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/kyungminlee/MinimalPerfectHash.jl
