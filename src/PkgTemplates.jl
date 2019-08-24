module PkgTemplates

using Base: @kwdef, current_project
using Base.Filesystem: contractuser
using Dates: month, today, year
using InteractiveUtils: subtypes
using LibGit2: LibGit2
using Mustache: render
using Pkg: PackageSpec, Pkg
using REPL.TerminalMenus: MultiSelectMenu, RadioMenu, request
using URIParser: URI

export
    # Template/package generation.
    Template,
    generate,
    # Licenses.
    show_license,
    available_licenses,
    # Plugins.
    AppVeyor,
    CirrusCI,
    Citation,
    Codecov,
    Coveralls,
    Documenter,
    GitLabCI,
    TravisCI

const default_version = VersionNumber(VERSION.major)

"""
A plugin to be added to a [`Template`](@ref), which adds some functionality or integration.
"""
abstract type Plugin end

include("licenses.jl")
include("template.jl")
include("generate.jl")
include("plugin.jl")
include("utils.jl")
include("interactive.jl")
include(joinpath("plugins", "generated.jl"))
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

end
