using MinimalPerfectHash
using Test
using Random


@testset "MinimalPerfectHash.jl" begin
    for K in [Int, UInt8, UInt64, Float64]
        for V in [Int, Float64]
            for n in [0, 1, 2, 3, 4, 5, 8, 9, 27, 32, 33, 64, 65, 1024, 1025, 65536, 65537]
                ks = collect(Set(Random.rand(K, n)))
                vs = rand(V, length(ks))
                chd = MinimalPerfectHash.CHD((k, v) for (k, v) in zip(ks, vs))
                chd = MinimalPerfectHash.CHD{K, V}((k, v) for (k, v) in zip(ks, vs))

                @test all(haskey(chd, k) for k in ks)
                @test all((k => v) in chd for (k, v) in zip(ks, vs))
                @test all(chd[k] == v for (k, v) in zip(ks, vs))
                @test length(chd) == length(ks)
                @test all(get(chd, k, nothing) == v for (k, v) in zip(ks, vs))
                @test all(getkey(chd, k, nothing) == k for k in ks)
                @test all(k in keys(chd) for k in ks)
                if n == 0
                    @test isempty(chd)
                else
                    @test sum(1 for (_, _) in chd) == length(ks)
                end
            end
        end
    end

end
