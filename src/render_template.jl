tags(::Type{<:Plugin}) = "{{", "}}"

function render_string(file::AbstractString, view, tags)
    # TODO: render_from_file.
    return render(read(file, String), view; tags=tags)
end

function _string(p::P<:BasicPlugin, t::Template, pkg_name::AbstractString)
    subs = merge(Dict("PKGNAME" => pkg_name, "USER" => t.user), view(p, t))
    return render_template(source(p, t), subs, curlies(P))
end
