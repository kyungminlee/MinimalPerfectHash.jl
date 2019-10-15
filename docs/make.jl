using Documenter, MinimalPerfectHash

makedocs(;
    modules=[MinimalPerfectHash],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/kyungminlee/MinimalPerfectHash.jl/blob/{commit}{path}#L{line}",
    sitename="MinimalPerfectHash.jl",
    authors="Kyungmin Lee",
    assets=String[],
)

deploydocs(;
    repo="github.com/kyungminlee/MinimalPerfectHash.jl",
)
