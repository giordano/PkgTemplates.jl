using Base.Filesystem: path_separator

using Pkg: Pkg
using Random: Random
using Test: @test, @testset, @test_throws

using ReferenceTests: @test_reference

using PkgTemplates
const PT = PkgTemplates

const PKG = "TestPkg"
const USER = "tester"

Random.seed!(1)

tpl(; kwargs...) = Template(; user=USER, kwargs...)

function with_pkg(f::Function, t::Template, pkg::AbstractString=PKG)
    t(pkg)
    try
        f(pkg)
    finally
        haskey(Pkg.installed(), pkg) && Pkg.rm(pkg)
        rm(joinpath(t.dir, pkg); recursive=true, force=true)
    end
end

@testset "PkgTemplates.jl" begin
    mktempdir() do dir
        Pkg.activate(dir)
        pushfirst!(DEPOT_PATH, dir)
        try
            include("template.jl")
            include("plugin.jl")

            # Quite a bit of output depends on the Julia version, and the test fixtures are
            # made with Julia 1.2. Also, Windows uses CRLF which breaks everything.
            if !Sys.iswindows() && VERSION.major == 1 && VERSION.minor == 2
                include("reference.jl")
            else
                @info "Skipping reference tests" julia=VERSION
            end
        finally
            popfirst!(DEPOT_PATH)
        end
    end
end
