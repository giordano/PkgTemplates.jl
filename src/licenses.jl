const LICENSE_DIR = normpath(joinpath(@__DIR__, "..", "licenses"))
const LICENSES = Dict(
    "MIT" => "MIT \"Expat\" License",
    "BSD2" => "Simplified \"2-clause\" BSD License",
    "BSD3" => "Modified \"3-clause\" BSD License",
    "ISC" => "Internet Systems Consortium License",
    "ASL" => "Apache License, Version 2.0",
    "MPL" => "Mozilla Public License, Version 2.0",
    "GPL-2.0+" => "GNU Public License, Version 2.0+",
    "GPL-3.0+" => "GNU Public License, Version 3.0+",
    "LGPL-2.1+" => "Lesser GNU Public License, Version 2.1+",
    "LGPL-3.0+" => "Lesser GNU Public License, Version 3.0+",
    "EUPL-1.2+" => "European Union Public Licence, Version 1.2+",
)

"""
    available_licenses([io::IO]) -> Nothing

Print the names of all available licenses.
"""
available_licenses(io::IO=stdout) = print(io, join(("$k: $v" for (k, v) in LICENSES), "\n"))

"""
    show_license([io::IO], license::AbstractString) -> Nothing

Print the text of `license`. Errors if the license is not found.
"""
show_license(io::IO, license::AbstractString) = println(io, read_license(license))
show_license(license::AbstractString) = show_license(stdout, license)

function license_path(license::AbstractString)
    path = joinpath(LICENSE_DIR, license)
    isfile(path) || throw(ArgumentError("License '$license' is not available"))
    return path
end

# Read the contents of a license.
read_license(license::AbstractString) = string(readchomp(license_path(license)))
