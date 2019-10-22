struct CHD{K, V} <:AbstractDict{K, V}
  slots ::Vector{Bool}
  keys ::Vector{K}
  vals ::Vector{V}
  count ::Int

  r ::Vector{UInt64}
  indices ::Vector{UInt16}
end

"""
one-based. negative means not found
"""
function chd_keyindex(c ::CHD{K, V}, key ::K) ::Int where {K, V}
  r0 = c.r[1]
  h = hash(key) ⊻ r0
  i = h % UInt64(length(c.indices))
  @inbounds ri = c.indices[i+1]

  ri >= UInt16(length(c.r)) && return -1

  @inbounds r = c.r[ri+1]
  ti = (h ⊻ r) % UInt64(length(c.keys))

  @inbounds (!c.slots[ti+1]) && return -1
  @inbounds (c.keys[ti+1] != key) && return -1

  return ti+1
end

@inline function Base.getindex(c ::CHD{K, V}, key) where {K, V}
  ti = chd_keyindex(c, K(key))
  ti <= 0 && throw(KeyError("key $key not found"))
  return c.vals[ti]
end

@inline function Base.length(c ::CHD) ::Int
  return c.count
end

@inline function Base.iterate(c ::CHD{K, V}, count::Int=1) ::Union{Nothing, Tuple{Pair{K, V}, Int}} where {K, V}
  # skip empty slots
  while count <= length(c.keys) && !c.slots[count]
    count += 1
  end
  count > length(c.keys) && return nothing
  return ((c.keys[count] => c.vals[count]), count+1)
end

@inline function Base.in(k, keys ::Base.KeySet{K, CHD{K,V}}) where {K, V}
  ti = chd_keyindex(keys.dict, K(k))
  return ti > 0
end

@inline function Base.get(h::CHD{K,V}, key, default) where {K, V}
    index = chd_keyindex(h, key)
    @inbounds return (index <= 0) ? default : h.vals[index]::V
end

@inline function Base.getkey(h::CHD{K,V}, key, default) where {K, V}
    index = chd_keyindex(h, key)
    @inbounds return (index <= 0) ? default : h.keys[index]::K
end
