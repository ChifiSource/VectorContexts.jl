module Contexts
using Toolips
using ToolipsSVG
using Random

abstract type AbstractContext <: Toolips.Modifier

mutable struct Context <: Toolips.Modifier
    window::Component{:svg}
    uuid::String
    layers::Dict{String, UnitRange{Int64}}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(wind::Component{:svg}, margin::Pair{Int64, Int64}) = begin
        new(wind, randstring(), Dict{String, UnitRange{Int64}}(), wind[:width] => wind[:height],
            margin)::Context
    end
    Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:svg} = svg("window", width = width,
        height = height)
        Context(window, margin)::Context
    end
end

function draw!(id::String, c::Context, comps::Vector{<:Servable})
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = Vector{Servable}(vcat(c.window[:children], comps))
    push!(c.layers, current_len + 1:comp_len)
end

function line!(con::Context, x::Vector{<:Number}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    if length(x) != length(y)
        throw(DimensionMismatch("x and y, of lengths $(length(x)) and $(length(y)) are not equal!"))
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
    percvec_x = map(n::Number -> n / xmax, x)
    percvec_y = map(n::Number -> n / ymax, y)
    line_data = join(Tuple(begin
                    scaled_x::Int64 = round(con.dim[1] * xper)  + con.margin[1]
                    scaled_y::Int64 = round(con.dim[2] * yper)  + con.margin[2]
                    "$(scaled_x)&#32;$(scaled_y),"
                end for (xper, yper) in zip(percvec_x, percvec_y)))
    line_comp = ToolipsSVG.polyline("newline", points = line_data)
    style!(line_comp, styles ...)
    draw!("newline", con, [line_comp])
end

end # - module
