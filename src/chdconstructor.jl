import Primes

#=
function CHD(the_keys ::AbstractVector{K},
             the_vals::AbstractVector{V};
             max_collisions::Integer=16777216) :: CHD{K, V} where {K, V}
  n ::UInt64 = max(17, UInt64(length(the_keys)))
  n = Primes.nextprime(n)
  m ::UInt64 = n ÷ 2

  slots = zeros(Bool, n)
  keys = Vector{K}(undef, n)
  vals = Vector{V}(undef, n)
  hasher = ChdHasher(n, m)
  buckets = [Bucket{K, V}(0, [], []) for i in 1:m]
  indices = [~UInt16(0) for i in 1:m]

  seen = Set{UInt64}()
  duplicates = Set{K}()

  for (key, val) in zip(the_keys, the_vals)
    (key in duplicates) && throw(ArgumentError("duplicate key $(string(key))"))
    push!(duplicates, key)

    oh = hash_index_from_key(hasher, key)
    buckets[oh+1].index = oh
    push!(buckets[oh+1].keys, key)
    push!(buckets[oh+1].vals, val)
  end

  collisions = 0
  sort!(buckets;
        lt=(lhs::Bucket{K,V}, rhs::Bucket{K,V}) -> length(lhs.keys) < length(rhs.keys),
        rev=true)

  # resolve each bucket
  for (i, bucket) in enumerate(buckets)
    isempty(bucket.keys) && continue
    next_bucket = false

    for (ri, r) in enumerate(hasher.r)
      # works with the existing r
      if try_hash(hasher, seen, slots, keys, vals, indices, bucket, UInt16(ri-1), r)
        next_bucket = true
        break
      end
    end
    next_bucket && continue

    # look for a new r
    for j in 1:max_collisions
      collisions = max(collisions, j)
      (ri, r) = generate(hasher)

      if try_hash(hasher, seen, slots, keys, vals, indices, bucket, ri, r)
        push!(hasher.r, r)
        next_bucket = true
        break
      end
    end
    next_bucket && continue

    @warn "max bucket collisions: $(collisions)"
    @warn "keys: $(length(the_keys))"
    @warn "hash functions: $(length(hasher.r))"

    @assert false "Failed to find a collision-free hash function after $(max_collisions) attempts, for bucket $i/$(length(buckets)) with $(length(bucket.keys)) entries"
  end

  return CHD{K, V}(slots, keys, vals, length(the_keys), hasher.r, indices)
end
=#

function CHD{K, V}(kv;
                   max_collisions::Integer=16777216) where {K, V}
  n ::UInt64 = max(17, UInt64(length(kv)))
  n = Primes.nextprime(n)
  m ::UInt64 = n ÷ 2

  slots = zeros(Bool, n)
  keys = Vector{K}(undef, n)
  vals = Vector{V}(undef, n)
  hasher = ChdHasher(n, m)
  buckets = [Bucket{K, V}(0, [], []) for i in 1:m]
  indices = [~UInt16(0) for i in 1:m]

  seen = Set{UInt64}()
  duplicates = Set{K}()

  for (key, val) in kv
    (key in duplicates) && throw(ArgumentError("duplicate key $(string(key))"))
    push!(duplicates, key)

    oh = hash_index_from_key(hasher, key)
    buckets[oh+1].index = oh
    push!(buckets[oh+1].keys, key)
    push!(buckets[oh+1].vals, val)
  end

  collisions = 0
  sort!(buckets;
        lt=(lhs::Bucket{K,V}, rhs::Bucket{K,V}) -> length(lhs.keys) < length(rhs.keys),
        rev=true)

  # resolve each bucket
  for (i, bucket) in enumerate(buckets)
    isempty(bucket.keys) && continue
    next_bucket = false

    for (ri, r) in enumerate(hasher.r)
      # works with the existing r
      if try_hash(hasher, seen, slots, keys, vals, indices, bucket, UInt16(ri-1), r)
        next_bucket = true
        break
      end
    end
    next_bucket && continue

    # look for a new r
    for j in 1:max_collisions
      collisions = max(collisions, j)
      (ri, r) = generate(hasher)

      if try_hash(hasher, seen, slots, keys, vals, indices, bucket, ri, r)
        push!(hasher.r, r)
        next_bucket = true
        break
      end
    end
    next_bucket && continue

    @warn "max bucket collisions: $(collisions)"
    @warn "keys: $(length(kv))"
    @warn "hash functions: $(length(hasher.r))"

    @assert false "Failed to find a collision-free hash function after $(max_collisions) attempts, for bucket $i/$(length(buckets)) with $(length(bucket.keys)) entries"
  end

  return CHD{K, V}(slots, keys, vals, length(kv), hasher.r, indices)
end


function CHD{K, V}(p::Pair; kwargs...) where {K, V}
  return CHD{K, V}([(p.first, p.second)])
end

function CHD{K, V}(ps::Pair...; kwargs...) where V where K
  return CHD{K, V}(ps; kwargs...)
end

function CHD(kv; kwargs...)
  try
    Base.dict_with_eltype((K, V) -> ((x...) -> CHD{K, V}(x...; kwargs...) ), kv, eltype(kv))
  catch
    if !Base.isiterable(typeof(kv)) || !all(x->isa(x,Union{Tuple,Pair}),kv)
      throw(ArgumentError("Dict(kv): kv needs to be an iterator of tuples or pairs"))
    else
      rethrow()
    end
  end
end

CHD(; kwargs...) = CHD{Any, Any}(; kwargs...)
CHD(kv::Tuple{}; kwargs...) = CHD(; kwargs...)
copy(d::CHD{K,V}; kwargs...) where {K, V} = CHD{K, V}(d; kwargs...)
CHD(ps::Pair{K, V}...; kwargs...) where {K, V} = CHD{K, V}(ps; kwargs...)
CHD(ps::Pair...; kwargs...)                    = CHD(ps; kwargs...)


# END MIMIC

# function CHD(ps::Pair{K,V}...;
#              max_collisions::Integer=16777216) where V where K
#   ks = K[p.first for p in ps]
#   vs = V[p.second for p in ps]
#   return CHD(ks, vs; max_collisions=max_collisions)
# end



function try_hash(
    hasher ::ChdHasher,
    seen ::Set{UInt64},

    slots ::Vector{Bool},
    keys ::Vector{K},
    vals ::Vector{V},
    indices ::Vector{UInt16},
    bucket ::Bucket{K, V},
    ri ::UInt16,
    r ::UInt64
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
    slots[h+1] = true
    keys[h+1] = bucket.keys[i]
    vals[h+1] = bucket.vals[i]
  end
  return true
end
