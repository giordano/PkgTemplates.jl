abstract type Coverage <: Plugin end

const COVERAGE_GITIGNORE = ["*.jl.cov", "*.jl.*.cov", "*.jl.mem"]

gitignore(::Coverage) = COVERAGE_GITIGNORE

@kwdef struct Codecov <: Coverage
    file::Union{String, Nothing} = nothing
end

source(p::Codecov) = p.file
destination(::Codecov) = ".codecov.yml"

badges(::Codecov) = Badge(
    "Coverage",
    "https://codecov.io/gh/{{USER}}/{{PKGNAME}}.jl/branch/master/graph/badge.svg",
    "https://codecov.io/gh/{{USER}}/{{PKGNAME}}.jl",
)

struct Coveralls <: Coverage
    file::Union{String, Nothing} = nothing
end

source(p::Coveralls) = p.file
destination(::Coveralls) = ".coveralls.yml"

badges(::Coveralls) = Badge(
    "Coverage",
    "https://coveralls.io/repos/github/{{USER}}/{{PKGNAME}}.jl/badge.svg?branch=master",
    "https://coveralls.io/github/{{USER}}/{{PKGNAME}}.jl?branch=master",
)
