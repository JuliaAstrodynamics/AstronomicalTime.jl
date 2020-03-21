import Dates

import ..AstroDates: DateTime, year, month, day,
    hour, minute, second, millisecond,
    time, date, fractionofday, yearmonthday, dayofyear

timescale(ep::Epoch) = ep.scale

"""
    DateTime(ep::Epoch)

Convert the epoch `ep` to an `AstroDates.DateTime`.
"""
function DateTime(ep::Epoch)
    if !isfinite(ep.fraction)
        if ep.fraction < 0
            return DateTime(AstroDates.MIN_EPOCH, AstroDates.H00)
        else
            return DateTime(AstroDates.MAX_EPOCH, Time(23, 59, 59.999))
        end
    end

    offset2000B = ep.fraction
    offset2000A = ep.second + Int64(43200)
    if offset2000B < 0
        offset2000A -= 1
        offset2000B += 1
    end
    time = offset2000A % Int64(86400)
    if time < 0
        time += Int64(86400)
    end
    date = Int((offset2000A - time) ÷ Int64(86400))

    date_comp = Date(AstroDates.J2000_EPOCH, date)
    time_comp = Time(time, offset2000B)

    leap = getleap(ep)
    leap = ifelse(abs(leap) == 1.0, leap, 0.0)
    if !iszero(leap)
        h = hour(time_comp)
        m = minute(time_comp)
        s = second(Float64, time_comp) + leap
        time_comp = Time(h, m, s)
    end

    DateTime(date_comp, time_comp)
end

"""
    year(ep::Epoch)

Get the year of the epoch `ep`.
"""
year(ep::Epoch) = year(DateTime(ep))

"""
    month(ep::Epoch)

Get the month of the epoch `ep`.
"""
month(ep::Epoch) = month(DateTime(ep))

"""
    day(ep::Epoch)

Get the day of the epoch `ep`.
"""
day(ep::Epoch) = day(DateTime(ep))

"""
    yearmonthday(ep::Epoch)

Get the year, month, and day of the epoch `ep` as a tuple.
"""
yearmonthday(ep::Epoch) = yearmonthday(DateTime(ep))

"""
    dayofyear(ep::Epoch)

Get the day of the year of the epoch `ep`.
"""
dayofyear(ep::Epoch) = dayofyear(DateTime(ep))

"""
    hour(ep::Epoch)

Get the hour of the epoch `ep`.
"""
hour(ep::Epoch) = hour(DateTime(ep))

"""
    minute(ep::Epoch)

Get the minute of the epoch `ep`.
"""
minute(ep::Epoch) = minute(DateTime(ep))

"""
    second(type, ep::Epoch)

Get the second of the epoch `ep` as a `type`.
"""
second(typ, ep::Epoch) = second(typ, DateTime(ep))

"""
    second(ep::Epoch) -> Int

Get the second of the epoch `ep` as an `Int`.
"""
second(ep::Epoch) = second(Int, DateTime(ep))

"""
    millisecond(ep::Epoch)

Get the number of milliseconds of the epoch `ep`.
"""
millisecond(ep::Epoch) = millisecond(DateTime(ep))

"""
    time(ep::Epoch)

Get the time of the epoch `ep`.
"""
time(ep::Epoch) = time(DateTime(ep))

"""
    date(ep::Epoch)

Get the date of the epoch `ep`.
"""
date(ep::Epoch) = date(DateTime(ep))

"""
    fractionofday(ep::Epoch)

Get the time of the day of the epoch `ep` as a fraction.
"""
fractionofday(ep::Epoch) = fractionofday(time(ep))

"""
    Dates.DateTime(ep::Epoch)

Convert the epoch `ep` to a `Dates.DateTime`.
"""
Dates.DateTime(ep::Epoch) = Dates.DateTime(DateTime(ep))

