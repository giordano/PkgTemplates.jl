# TODO deal with formatting the current version properly


const DEFAULT_CI_VERSIONS = ["1.0", "nightly"]
const VersionsOrStrings = Vector{Union{VersionNumber, String}}

format_version(v::VersionNumber) = "$(v.major).$(v.minor)"

function collect_versions(versions::Vector, t::Template)
    return unique(sort([versions; format_version(t.julia_version)]; by=string))
end

abstract type CI <: Plugin end

@kwdef struct TravisCI <: CI
    # TODO: Windows 32-bit?
    file::String = default_file("travis.yml")
    linux::Bool = true
    osx::Bool = true
    windows::Bool = true
    coverage::Bool = true
    extra_versions::VersionsOrStrings = DEFAULT_CI_VERSIONS
end

source(p::TravisCI) = p.file
destination(::TravisCI) = ".travis.yml"

badges(::TravisCI) = Badge(
    "Build Status",
    "https://travis-ci.com/{{USER}}/{{PKGNAME}}.jl.svg?branch=master",
    "https://travis-ci.com/{{USER}}/{{PKGNAME}}.jl",
)

function view(p::TravisCI, t::Template, ::AbstractString)
    os = String[]
    p.linux && push!(os, "linux")
    p.osx && push!(os, "osx")
    p.windows && push!(os, "windows")
    return Dict(
        "HAS_CODECOV" => hasplugin(t, Codecov),
        "HAS_COVERALLS" => hasplugin(t, Coveralls),
        "HAS_DOCUMENTER" => hasplugin(t, Documenter{TravisCI}),
        "HAS_COVERAGE" => p.coverage && hasplugin(t, Coverage),
        "HAS_NIGHTLY" => "nightly" in versions,
        "OS" => os,
        "VERSION" => t.julia_version,
        "VERSIONS" => collect_versions(p.extra_versions, t),
    )
end

@kwdef struct AppVeyor <: CI
    file::String = default_file("appveyor.yml")
    x86::Bool = false
    coverage::Bool = true
    extra_versions::VersionsOrStrings = DEFAULT_CI_VERSIONS
end

source(p::AppVeyor) = p.file
destination(::AppVeyor) = ".appveyor.yml"

badges(::AppVeyor) = Badge(
    "Build Status",
    "https://ci.appveyor.com/api/projects/status/github/{{USER}}/{{PKGNAME}}.jl?svg=true",
    "https://ci.appveyor.com/project/{{USER}}/{{PKGNAME}}-jl",
)

function view(p::AppVeyor, t::Template, ::AbstractString)
    platforms = ["x64"]
    t.x86 && push!(platforms, "x86")
    return Dict(
        "HAS_CODECOV" => t.coverage && hasplugin(t, Codecov),
        "HAS_NIGHTLY" => "nightly" in versions,
        "PLATFORMS" => os,
        "VERSIONS" => collect_versions(p.extra_versions, t),
    )
end

@kwdef struct CirrusCI <: CI
    file::String = default_file("cirrus.yml")
    image::String = "freebsd-12-0-release-amd64"
    coverage::Bool = true
    extra_versions::VersionsOrStrings = DEFAULT_CI_VERSIONS
end

source(p::CirrusCI) = p.file
destination(::CirrusCI) = ".cirrus.yml"

badges(::CirrusCI) = Badge(
    "Build Status",
    "https://api.cirrus-ci.com/github/{{USER}}/{{PACKAGE}}.jl.svg",
    "https://cirrus-ci.com/github/{{USER}}/{{PKGNAME}}.jl",
)

function view(p::CirrusCI, t::Template, ::AbstractString)
    return Dict(
        "HAS_CODECOV" => hasplugin(t, Codecov),
        "HAS_COVERALLS" => hasplugin(t, Coveralls),
        "HAS_COVERAGE" => p.coverage && hasplugin(t, Coverage),
        "IMAGE" => p.image,
        "VERSIONS" => collect_versions(p.extra_versions, t),
    )
end

@kwdef struct GitLabCI <: CI
    file::String
    documentation::Bool = true
    coverage::Bool = true
    extra_versions::Vector{VersionNumber} = [v"1.0"]
end

gitignore(p::GitLabCI) = p.coverage ? COVERAGE_GITIGNORE : String[]

source(p::GitLabCI) = p.source
destination(::GitLabCI) = ".gitlab-ci.yml"

function badges(p::GitLabCI)
    ci = Badge(
        "Build Status",
        "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/badges/master/build.svg",
        "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/pipelines",
    )
    cov = Badge(
        "Coverage",
        "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/badges/master/coverage.svg",
        "https://gitlab.com/{{USER}}/{{PKGNAME}}.jl/commits/master",
    )
    return p.coverage ? [ci, cov] : [ci]
end

function view(p::GitLabCI, t::Template, ::AbstractString)
    return Dict(
        "HAS_COVERAGE" => p.coverage,
        "HAS_DOCUMENTER" => hasplugin(t, Documenter{GitLabCI}),
        "VERSION" => t.julia_version,
        "VERSIONS" => collect_versions(p.extra_versions, t),
    )
end
