@kwdef struct Readme <: BasicPlugin
    file::String = default_file("README.md")
    destination::String = "README.md"
end

source(p::Readme) = p.file
destination(p::Readme) = p.destination

function view(::Readme, t::Template, pkg::AbstractString)
    # Explicitly ordered badges go first.
    badges = String[]
    done = DataType[]
    foreach(BADGE_ORDER) do T
        if hasplugin(t, T)
            bs = badges(t.plugins[T], t, pkg)
            text *= "\n" * join(badges(t.plugins[T], t.user, pkg), "\n")
            push!(done, T)
        end
    end
    foreach(setdiff(keys(t.plugins), done)) do T
        bs = badges(t.plugins[T], t, pkg)
        text *= "\n" * join(badges(t.plugins[T], t.user, pkg), "\n")
    end

    Dict("HAS_CITATION" => hasplugin(t, Citation))
end

struct License <: Plugin
    path::String
    destination::String

    function License(name::AbstractString; destination::AbstractString="LICENSE")
        return new(license_path(name), destination)
    end
end

function render_file(p::License, t::Template)
    text = "Copyright (c) $(year(today())) $(t.authors)\n"
    license = read(p.path, String)
    startswith(license, "\n") || (text *= "\n")
    return text * license
end

function gen_plugin(p::License, t::Template, pkg_dir::AbstractString)
    gen_file(joinpath(pkg_dir, p.destination), render_file(p, t))
end

struct Gitignore <: Plugin end

function render_file(p::Gitignore, t::Template)
    entries = mapreduce(gitignore, append!, values(t.plugins); init=[".DS_Store", "/dev/"])
    # Only ignore manifests at the repo root.
    t.manifest || "Manifest.toml" in entries || push!(entries, "/Manifest.toml")
    unique!(sort!(entries))
    return join(entries, "\n")
end

function gen_plugin(p::Gitignore, t::Template, pkg_dir::AbstractString)
    gen_file(joinpath(pkg_dir, ".gitignore"), render_file(p, t))
end

struct Tests <: Plugin end

function gen_plugin(p::Tests, ::Template, pkg_dir::AbstractString)
end
