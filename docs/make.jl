using Documenter, MinimalPerfectHash

makedocs(;
    modules=[MinimalPerfectHash],
    doctest=true,
    sitename="MinimalPerfectHash.jl",
    format=Documenter.HTML(),
    authors="Kyungmin Lee",
    checkdocs=:all,
    pages=[
        "Home" => "index.md",
    ],
    assets=String[],
)

deploydocs(;
    repo="github.com/kyungminlee/MinimalPerfectHash.jl",
    devbranch="dev",
)
