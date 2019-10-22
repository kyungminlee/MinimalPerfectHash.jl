import Primes

function CHD{K, V}(kv;
                   max_collisions::Integer=16777216,
                   gamma::Real=1.25,
                   check_duplicates::Bool=true) where {K, V}
  !(gamma >= 1.0) && throw(ArgumentError("gamma needs to be no less than 1"))
  count = length(kv)
  n ::UInt64 = max(17, UInt64(ceil(count * gamma)))
  n < count && throw(OverflowError("count * gamma is bigger than typemax(UInt64)"))
  #@info "Finding nextprime($n)"
  n = Primes.nextprime(n)
  #@info "The prime is $n"
  m ::UInt64 = Primes.nextprime(n ÷ 2)

  slots = zeros(Bool, n)
  keys = Vector{K}(undef, n)
  vals = Vector{V}(undef, n)
  hasher = ChdHasher(n, m)
  buckets = [Bucket{K, V}(0, [], []) for i in 1:m]
  indices = [~UInt16(0) for i in 1:m]

  seen = Set{UInt64}()

  if check_duplicates
    duplicates = Set{K}()
    for (key, val) in kv
      (key in duplicates) && throw(ArgumentError("duplicate key $(string(key))"))
      push!(duplicates, key)
    end
  end

  for (key, val) in kv
    oh = hash_index_from_key(hasher, key)
    @inbounds bucket = buckets[oh+1]
    bucket.index = oh
    push!(bucket.keys, key)
    push!(bucket.vals, val)
  end

  filter!((arg::Bucket{K,V}) -> !isempty(arg.keys), buckets)

  collisions = 0
  sort!(buckets;
        lt=(lhs::Bucket{K,V}, rhs::Bucket{K,V}) -> length(lhs.keys) < length(rhs.keys))

  # resolve each bucket
  i = 0
  while !isempty(buckets)
    i += 1
    bucket = pop!(buckets)
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

    error("Failed to find a collision-free hash function after $(max_collisions) attempts, " *
          "for bucket $i/$(length(buckets)) with $(length(bucket.keys)) entries." *
          "max bucket collisions: $(collisions), " *
          "keys: $count, " *
          "hash functions: $(length(hasher.r))")
  end

  return CHD{K, V}(slots, keys, vals, count, hasher.r, indices)
end


function CHD{K, V}(p::Pair; kwargs...) ::CHD{K, V} where {K, V}
  return CHD{K, V}([(p.first, p.second)])
end

function CHD{K, V}(ps::Pair...; kwargs...) ::CHD{K, V} where V where K
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
copy(d::CHD{K,V}) where {K, V} = CHD{K, V}(copy(d.slots), Base.copy(d.keys), copy(d.vals), d.count, copy(d.r), copy(d.indices))
CHD(ps::Pair{K, V}...; kwargs...) where {K, V} = CHD{K, V}(ps; kwargs...)
CHD(ps::Pair...; kwargs...)                    = CHD(ps; kwargs...)
