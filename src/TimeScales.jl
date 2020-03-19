module TimeScales

using ItemGraphs: ItemGraph, add_edge!, add_vertex!, items

import Dates

export TimeScale, find_path, link_scales!, register_scale!

"""
All timescales are subtypes of the abstract type `TimeScale`.
The following timescales are defined:

* `UTC` — Coordinated Universal Time
* `UT1` — Universal Time
* `TAI` — International Atomic Time
* `TT` — Terrestrial Time
* `TCG` — Geocentric Coordinate Time
* `TCB` — Barycentric Coordinate Time
* `TDB` — Barycentric Dynamical Time
"""
abstract type TimeScale end

const NAMES = (
    :CoordinatedUniversalTime,
    :UniversalTime,
    :InternationalAtomicTime,
    :TerrestrialTime,
    :GeocentricCoordinateTime,
    :BarycentricCoordinateTime,
    :BarycentricDynamicalTime,
)

const ACRONYMS = (
    :UTC,
    :UT1,
    :TAI,
    :TT,
    :TCG,
    :TCB,
    :TDB,
)

for (acronym, scale) in zip(ACRONYMS, NAMES)
    name = String(acronym)
    @eval begin
        struct $scale <: TimeScale end
        const $acronym = $scale()
        export $scale, $acronym

        Base.show(io::IO, ::$scale) = print(io, "$($name)")
        tryparse(::Val{Symbol($name)}) = $acronym
    end
end

const SCALES = ItemGraph{TimeScale}()

function register_scale!(s)
    add_vertex!(SCALES, s)
end

function link_scales!(s1, s2; oneway=false)
    add_edge!(SCALES, s1, s2)
    oneway || add_edge!(SCALES, s2, s1)
end

link_scales!(TAI, TT)
link_scales!(TAI, UTC)
link_scales!(UTC, UT1)
link_scales!(TT, TCG)
link_scales!(TT, TDB)
link_scales!(TCB, TDB)

find_path(from, to) = items(SCALES, from, to)

struct NotATimeScale <: TimeScale end

tryparse(s::T) where T<:AbstractString = tryparse(Val(Symbol(s)))
tryparse(::T) where T = nothing

@inline function Dates.tryparsenext(d::Dates.DatePart{'t'}, str, i, len, locale)
    next = Dates.tryparsenext_word(str, i, len, locale, Dates.max_width(d))
    next === nothing && return nothing
    word, i = next
    val = tryparse(word)
    val === nothing && throw(ArgumentError("'$word' is not a recognized time scale."))
    return val, i
end

end
