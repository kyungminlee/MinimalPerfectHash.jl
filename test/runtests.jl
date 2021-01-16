using MinimalPerfectHash
using Test
using Random


@testset "MinimalPerfectHash.jl" begin

    @testset "EmptyConstructor" begin
        chd = MinimalPerfectHash.CHD()
        @test typeof(chd) == MinimalPerfectHash.CHD{Any, Any}
        @test length(chd) == 0
        for (_, _) in chd
            @test false
        end
        chd = MinimalPerfectHash.CHD( () )
        @test typeof(chd) == MinimalPerfectHash.CHD{Any, Any}
        @test length(chd) == 0
        for (_, _) in chd
            @test false
        end

    end

    let
        chd = MinimalPerfectHash.CHD(1=>"Bye")
        @test typeof(chd) == MinimalPerfectHash.CHD{Int, String}
        chd = MinimalPerfectHash.CHD("Hello" => "World")
        @test typeof(chd) == MinimalPerfectHash.CHD{String, String}
        MinimalPerfectHash.CHD{UInt, Int}(0x1 => 2)
        MinimalPerfectHash.CHD(UInt8(1) => 2, UInt16(2) => 3, UInt(3) => 10)
        chd2 = copy(chd)
        @test chd2 !== chd
        @test chd2 == chd
    end

    @testset "Exceptions" begin
        @test_throws ArgumentError MinimalPerfectHash.CHD(1=>2, 1=>3)
        @test_throws ArgumentError MinimalPerfectHash.CHD([1,2,3])
    end

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

    let K=Int, V=Int, n=(1<<3)
        ks = sort(unique(Random.rand(K, n)))
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
