"""
    Template(interactive::Bool=false; kwargs...) -> Template

Records common information used to generate a package.

## Keyword Arguments
* `user::AbstractString=""`: GitHub (or other code hosting service) username.
  If left unset, it will take the the global Git config's value (`github.user`).
  If that is not set, an `ArgumentError` is thrown.
  This is case-sensitive for some plugins, so take care to enter it correctly!
* `host::AbstractString="github.com"`: URL to the code hosting service where your package will reside.
  Note that while hosts other than GitHub won't cause errors, they are not officially supported and they will cause certain plugins will produce incorrect output.
* `license::AbstractString="MIT"`: Name of the package license.
  If an empty string is given, no license is created.
  See [`available_licenses`](@ref) to list all available licenses, and [`show_license`](@ref) to read a particular license.
* `authors::Union{AbstractString, Vector{<:AbstractString}}=""`: Names that appear on the license.
  Supply a string for one author or an array for multiple.
  Similarly to `user`, it will take the value of of the global Git config's value if it is left unset.
* `dir::AbstractString=$(contractuser(Pkg.devdir()))`: Directory in which the package will go.
  Relative paths are converted to absolute ones at template creation time.
* `julia_version::VersionNumber=$default_version`: Minimum allowed Julia version.
* `ssh::Bool=false`: Whether or not to use SSH for the git remote. If `false` HTTPS will be used.
* `manifest::Bool=false`: Whether or not to commit the `Manifest.toml`.
* `git::Bool=true`: Whether or not to create a Git repository for generated packages.
* `develop::Bool=true`: Whether or not to `develop` generated packages in the active environment.
* `plugins::Vector{<:Plugin}=Plugin[]`: A list of plugins that the package will include.
* `interactive::Bool=false`: When set, creates the template interactively from user input,
  using the previous keywords as a starting point.
* `fast::Bool=false`: Only applicable when `interactive` is set.
  Skips prompts for any unsupplied keywords except `user` and `plugins`.
"""
struct Template
    user::String
    host::String
    license::String
    authors::String
    dir::String
    julia_version::VersionNumber
    ssh::Bool
    dev::Bool
    manifest::Bool
    git::Bool
    develop::Bool
    plugins::Dict{DataType, <:Plugin}
end

Template(; interactive::Bool=false, kwargs...) = make_template(Val(interactive); kwargs...)

function make_template(::Val{false}; kwargs...)
    user = getkw(kwargs, :user)
    if isempty(user)
        throw(ArgumentError("No username found, set one with user=username"))
    end

    host = getkw(kwargs, :host)
    host = URI(occursin("://", host) ? host : "https://$host").host

    license = getkw(kwargs, :license)
    if !isempty(license) && !isfile(joinpath(LICENSE_DIR, license))
        throw(ArgumentError("License '$license' is not available"))
    end

    authors = getkw(kwargs, :authors)
    if authors isa Vector
        authors = join(authors, ", ")
    end

    dir = abspath(expanduser(getkw(kwargs, :dir)))

    plugins = getkw(kwargs, :plugins)
    plugin_dict = Dict{DataType, Plugin}(typeof(p) => p for p in plugins)
    if length(plugins) != length(plugin_dict)
        @warn "Plugin list contained duplicates, only the last of each type was kept"
    end

    return Template(
        user,
        host,
        license,
        authors,
        dir,
        getkw(kwargs, :julia_version),
        getkw(kwargs, :ssh),
        getkw(kwargs, :manifest),
        getkw(kwargs, :git),
        getkw(kwargs, :develop),
        plugin_dict,
    )
end

getkw(kwargs, k) = get(() -> defaultkw(k), kwargs, k)

defaultkw(s::Symbol) = defaultkw(Val(s))
defaultkw(::Val{:user}) = LibGit2.getconfig("github.user", "")
defaultkw(::Val{:host}) = "https://github.com"
defaultkw(::Val{:license}) = "MIT"
defaultkw(::Val{:dir}) = Pkg.devdir()
defaultkw(::Val{:julia_version}) = default_version
defaultkw(::Val{:ssh}) = false
defaultkw(::Val{:manifest}) = false
defaultkw(::Val{:git}) = true
defaultkw(::Val{:develop}) = true
defaultkw(::Val{:plugins}) = Plugin[]
function defaultkw(::Val{:authors})
    name = LibGit2.getconfig("user.name", "")
    email = LibGit2.getconfig("user.email", "")
    isempty(name) && return ""
    author = name * " "
    isempty(email) || (author *= "<$email>")
    return strip(author)
end

function Base.show(io::IO, t::Template)
    println(io, "Template:")
    println(io, HALFTAB, ARROW, "User: ", maybe_string(t.user))
    println(io, HALFTAB, ARROW, "Host: ", maybe_string(t.host))

    print(io, HALFTAB, ARROW, "License: ")
    if isempty(t.license)
        println(io, "None")
    else
        println(io, t.license, " ($(t.authors) ", year(today()), ")")
    end

    println(io, HALFTAB, ARROW, "Package directory: ", contractuser(maybe_string(t.dir)))
    println(io, HALFTAB, ARROW, "Minimum Julia version: v", version_floor(t.julia_version))
    println(io, HALFTAB, ARROW, "SSH remote: ", yesno(t.ssh))
    println(io, HALFTAB, ARROW, "Commit Manifest.toml: ", yesno(t.manifest))
    println(io, HALFTAB, ARROW, "Create Git repository: ", yesno(t.git))
    println(io, HALFTAB, ARROW, "Develop packages: ", yesno(t.develop))

    print(io, HALFTAB, ARROW, "Plugins:")
    if isempty(t.plugins)
        print(io, " None")
    else
        foreach(sort(collect(values(t.plugins)); by=string)) do p
            print(io, "\n", TAB, DOT, padtail(sprint(show, p), TAB * HALFTAB))
        end
    end
end
