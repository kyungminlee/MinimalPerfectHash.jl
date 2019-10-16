import Random

mutable struct ChdHasher
  r ::Vector{UInt64}
  size ::UInt64
  buckets ::UInt64
  rng ::Random.AbstractRNG
end

mutable struct Bucket{K,V}
  index ::UInt64
  keys :: Vector{K}
  vals :: Vector{V}
end

function ChdHasher(size ::UInt64, buckets ::UInt64; rng ::Random.AbstractRNG=Random.GLOBAL_RNG)
  return ChdHasher([rand(rng, UInt64)], size, buckets, rng)
end

function hash_index_from_key(h ::ChdHasher, k ::K) ::UInt64 where K
  return (hash(k) ⊻ h.r[1]) % h.buckets
end

function table(h ::ChdHasher, r ::UInt64, k ::K) ::UInt64 where K
  return ( (hash(k) ⊻ h.r[1]) ⊻ r) % h.size
end

function generate(c ::ChdHasher) :: Tuple{UInt16, UInt64}
    return UInt16(length(c.r)), rand(c.rng, UInt64)
end
