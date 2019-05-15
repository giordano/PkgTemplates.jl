"""
    Citation(; readme_section::Bool=false) -> Citation

Add `Citation` to a [`Template`](@ref)'s plugin list to generate a `CITATION.bib` file.
If `readme_section` is set, then generated packages' README files will contain a section about citing.
"""
struct Citation <: Plugin
    readme_section::Bool

    Citation(; readme_section::Bool=false) = new(readme_section)
end

function gen_plugin(p::Citation, t::Template, pkg_name::AbstractString)
    pkg_dir = joinpath(t.dir, pkg_name)
    text = """
       @misc{$pkg_name.jl,
       \tauthor  = {{$(t.authors)}},
       \ttitle   = {{$pkg_name.jl}},
       \turl     = {https://$(t.host)/$(t.user)/$pkg_name.jl},
       \tversion = {v0.1.0},
       \tyear    = {$(year(today()))},
       \tmonth   = {$(month(today()))}
       }
       """
    gen_file(joinpath(t.dir, pkg_name, "CITATION.bib"), text)
    return ["CITATION.bib"]
end

function interactive(::Type{Citation})
    readme = prompt_bool("Citation: Add a section to the README", false)
    return Citation(; readme_section=readme)
end

function Base.show(io::IO, p::Citation)
    print(io, "Citation: README section ", p.readme_section ? "enabled" : "disabled")
end
