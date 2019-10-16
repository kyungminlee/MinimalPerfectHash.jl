using MinimalPerfectHash
using Test
using Random


@testset "MinimalPerfectHash.jl" begin
    for K in [Int, UInt8, UInt64, Float64]
        for V in [Int, Float64]
            for n in [0, 1, 2, 3, 4, 5, 8, 9, 27, 32, 33, 64, 65, 1024, 1025, 65536, 65537]
                keys = collect(Set(Random.rand(K, n)))
                vals = rand(V, length(keys))
                chd = MinimalPerfectHash.CHD(keys, vals)

                @test all(haskey(chd, k) for k in keys)
                @test all((k => v) in chd for (k, v) in zip(keys, vals))
                @test all(chd[k] == v for (k, v) in zip(keys, vals))
                @test length(chd) == length(keys)
                @test all(get(chd, k, nothing) == v for (k, v) in zip(keys, vals))
                @test all(getkey(chd, k, nothing) == k for k in keys)
                if n == 0
                    @test isempty(chd)
                else
                    @test sum(1 for (_, _) in chd) == length(keys)
                end
            end
        end
    end

end
