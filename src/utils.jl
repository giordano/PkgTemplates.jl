# Printing utils.
const TAB = repeat(' ', 4)
const HALFTAB = repeat(' ', 2)
const DOT = "• "
const ARROW = "→ "
yesno(x::Bool) = x ? "Yes" : "No"
maybe_string(s::AbstractString) = isempty(s) ? "None" : string(s)

# Default template directory.
const DEFAULTS_DIR = normpath(joinpath(@__DIR__, "..", "defaults"))
default_file(paths::AbstractString...) = joinpath(DEFAULTS_DIR, paths...)

"""
    gen_file(file::AbstractString, text::AbstractString) -> Int

Create a new file containing some given text.
Trailing whitespace is removed, and the file will end with a newline.

## Arguments
* `file::AbstractString`: Path to the file to be created.
* `text::AbstractString`: Text to write to the file.
"""
function gen_file(file::AbstractString, text::AbstractString)
    mkpath(dirname(file))
    text = join(map(rstrip, split(text, "\n")), "\n")
    endswith(text , "\n") || (text *= "\n")
    write(file, text)
end

"""
    version_floor(v::VersionNumber=VERSION) -> String

Format the given Julia `version` as `"major.minor"` for the most recent release version relative to `v`.
For prereleases with `v.minor == v.patch == 0`, returns `"major.minor-"`.
"""
function version_floor(v::VersionNumber=VERSION)
    return if isempty(v.prerelease) || v.patch > 0
        "$(v.major).$(v.minor)"
    else
        "$(v.major).$(v.minor)-"
    end
end
