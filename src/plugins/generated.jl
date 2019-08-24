# Templating the file requires some changes to Mustache, I think.
# """
#     Citation(
#         file::Union{AbstractString, Nothing}=$(file_docstring(default_file("CITATION.bib")));
#         readme_section::Bool=false,
#     ) -> Citation

# Add `Citation` to a [`Template`](@ref)'s plugin list to generate a `CITATION.bib` file.
# If `readme_section` is set, then generated packages' README files will contain a section about citing.
# """
# @plugin Citation default_file("CITATION.bib") => "CITATION.bib" readme_section::Bool=false

"""
    GitLabCI(
        file::Union{AbstractString, Nothing}="<defaults>/gitlab-ci.yml";
        coverage::Bool=true,
    ) -> GitLabCI

Add `GitLabCI` to a [`Template`](@ref)'s plugin list to integrate your project with [GitLab CI](https://docs.gitlab.com/ce/ci).
If `coverage` is set, then code coverage analysis is enabled.
"""
@plugin GitLabCI default_file("gitlab-ci.yml") => ".gitlab-ci.yml" coverage::Bool=true
gitignore(p::GitLabCI) = p.coverage ? ["*.jl.cov", "*.jl.*.cov", "*.jl.mem"] : String[]
function badges(p::GitLabCI)
    build, coverage = [
        Badge(
            "Build Status",
            "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/badges/master/build.svg",
            "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/pipelines",
        ),
        Badge(
            "Coverage",
            "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/badges/master/coverage.svg",
            "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/commits/master",
        )
    ]
    badges = [build]
    p.coverage && push(badges, coverage)
    return bs
end
function interactive(::Type{GitLabCI})
    cfg = prompt_config(GitLabCI)
    coverage = prompt_bool("GitLabCI: Enable test coverage analysis", true)
    return GitLabCI(cfg; coverage=coverage)
end
function Base.show(io::IO, p::GitLabCI)
    invoke(show, Tuple{IO, GeneratedPlugin}, io, p)
    print(io, ", coverage ", p.coverage ? "enabled" : "disabled")
end
function Base.repr(p::GitLabCI)
    s = invoke(repr, Tuple{GeneratedPlugin}, p)[1:end-1]  # Remove trailing ')'.
    return "$s; coverage=$(p.coverage))"
end
