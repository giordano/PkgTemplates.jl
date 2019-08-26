const DEFAULTS_DIR = normpath(joinpath(@__DIR__, "..", "defaults"))

abstract type BasicPlugin <: Plugin end

default_file(paths::AbstractString...) = joinpath(DEFAULTS_DIR, paths...)

"""
    view(::Plugin, ::Template, pkg::AbstractString) -> Dict{String}

Return extra string substitutions to be made for this plugin.
"""
view(::Plugin, ::Template, ::AbstractString) = Dict{String, Any}()

"""
    gitignore(::Plugin) -> Vector{String}

Return patterns that should be added to `.gitignore`.
"""
gitignore(::Plugin) = String[]

"""
    badges(::Plugin) -> Union{Badge, Vector{Badge}}

Return a list of [`Badge`](@ref)s, or just one, to be added to `README.md`.
"""
badges(::Plugin) = Badge[]

"""
    source(::BasicPlugin) -> Union{String, Nothing}

Return the path to a plugin's configuration file template, or `nothing` to indicate no file.
"""
source(::BasicPlugin) = nothing

"""
    destination(::BasicPlugin) -> String

Return the destination, relative to the package root, of a plugin's configuration file.
"""
function destination end

"""
    Badge(hover::AbstractString, image::AbstractString, link::AbstractString) -> Badge

Container for Markdown badge data.
Each argument can contain placeholders.

## Arguments
* `hover::AbstractString`: Text to appear when the mouse is hovered over the badge.
* `image::AbstractString`: URL to the image to display.
* `link::AbstractString`: URL to go to upon clicking the badge.
"""
struct Badge
    hover::String
    image::String
    link::String
end

Base.string(b::Badge) = "[![$(b.hover)]($(b.image))]($(b.link))"

# Format a plugin's badges as a list of strings, with all substitutions applied.
function badges(p::Plugin, t::Template, pkg_name::AbstractString)
    bs = badges(p)
    bs isa Vector || (bs = [bs])
    bs = map(string, bs)
    # TODO render
end

"""
    gen_plugin(p::Plugin, t::Template, pkg::AbstractString) -> Nothing

Generate any files associated with a plugin.

## Arguments
* `p::Plugin`: Plugin whose files are being generated.
* `t::Template`: Template configuration.
* `pkg::AbstractString`: Name of the package.
"""
gen_plugin(::Plugin, ::Template, ::AbstractString) = nothing

function gen_plugin(p::BasicPlugin, t::Template, pkg::AbstractString)
    source(p) === nothing && return
    text = render(source(p), view(p, t, pkg); tags=tags(p))
    gen_file(joinpath(t.dir, pkg_name, destination(p)), text)
end

"""
    gen_file(file::AbstractString, text::AbstractString) -> Int

Create a new file containing some given text.
Trailing whitespace is removed, and the file will end with a newline.
"""
function gen_file(file::AbstractString, text::AbstractString)
    mkpath(dirname(file))
    text = join(map(rstrip, split(text, "\n")), "\n")
    endswith(text , "\n") || (text *= "\n")
    write(file, text)
end

render_file(file::AbstractString, view, tags) = render_text(read(file, String), view, tags)

render_text(text::AbstractString, view, tags) = render(text, view; tags=tags)

function render_badges(p::BasicPlugin, t::Template, pkg::AbstractString)
end

function render_plugin(p::BasicPlugin, t::Template, pkg::AbstractString)
    render_file(source(p), view(p, t, pkg), tags(p))
end

include(joinpath("plugins", "essentials.jl"))
include(joinpath("plugins", "coverage.jl"))
include(joinpath("plugins", "ci.jl"))
include(joinpath("plugins", "citation.jl"))
include(joinpath("plugins", "documenter.jl"))

const BADGE_ORDER = [
    Documenter{GitLabCI},
    Documenter{TravisCI},
    TravisCI,
    AppVeyor,
    GitLabCI,
    Codecov,
    Coveralls,
]
