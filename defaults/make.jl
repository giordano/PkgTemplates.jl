using {{PKGNAME}}
using Documenter

makedocs(
    modules=[{{PKGNAME}}],
    format=HTML({{ASSETS}}),
    pages=[
        "HOME" => "index.md",
    ],
    sitename="{{PKGNAME}}.jl"
    authors="{{AUTHORS}}"
    assets="{{ASSETS}}",

)
