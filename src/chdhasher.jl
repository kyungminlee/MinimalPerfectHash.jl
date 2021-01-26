import Random

mutable struct ChdHasher
    r::Vector{UInt64}
    size::UInt64
    buckets::UInt64
    rng::Random.AbstractRNG
end

mutable struct Bucket{K,V}
    index::UInt64
    keys::Vector{K}
    vals::Vector{V}
end

function ChdHasher(size::UInt64, buckets::UInt64; rng::Random.AbstractRNG=Random.GLOBAL_RNG)
    return ChdHasher([rand(rng, UInt64)], size, buckets, rng)
end

function hash_index_from_key(h::ChdHasher, k::K) ::UInt64 where K
    return (hash(k) ⊻ h.r[1]) % h.buckets
end

function table(h::ChdHasher, r::UInt64, k::K) ::UInt64 where K
    return ((hash(k) ⊻ h.r[1]) ⊻ r) % h.size
end

function generate(c::ChdHasher)::Tuple{UInt16, UInt64}
    return UInt16(length(c.r)), rand(c.rng, UInt64)
end

function try_hash(
    hasher::ChdHasher,
    seen::Set{UInt64},
    slots::Vector{UInt8},
    keys::Vector{K},
    vals::Vector{V},
    indices::Vector{UInt16},
    bucket::Bucket{K, V},
    ri::UInt16,
    r::UInt64
) where {K, V}

    duplicate = Set{UInt64}()
    hashes = Vector{UInt64}(undef, length(bucket.keys))
    for (i, k) in enumerate(bucket.keys)
        h = table(hasher, r, k)
        hashes[i] = h
        (h in seen) && return false
        (h in duplicate) && return false
        push!(duplicate, h)
    end
    union!(seen, hashes)
    indices[bucket.index+1] = ri

    for (i, h) in enumerate(hashes)
        slots[h+1] = 0x1
        keys[h+1] = bucket.keys[i]
        vals[h+1] = bucket.vals[i]
    end
    return true
end
