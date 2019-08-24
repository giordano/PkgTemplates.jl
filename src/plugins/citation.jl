"""
    Citation(; readme_section::Bool=false) -> Citation

Add `Citation` to a [`Template`](@ref)'s plugin list to generate a `CITATION.bib` file.
If `readme` is set, then `README.md` will contain a section about citing.
"""
@kwdef struct Citation <: BasicPlugin
    file::String = default_file("CITATION.bib")
    readme::Bool = false
end

source(p::Citation) = p.file
destination(::Citation) = "CITATION.bib"

view(::Citation, t::Template, pkg::AbstractString) = Dict(
    "AUTHORS" => t.authors,
    "MONTH" => month(today()),
    "URL" => "https://$(t.host)/$(t.user)/$pkg.jl",
    "YEAR" => year(today()),
)

function interactive(::Type{Citation})
    readme = prompt_bool("Citation: Add a section to the README", false)
    return Citation(; readme_section=readme)
end
