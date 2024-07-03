; extends

((template_string) @injection.content
  (#lua-match? @injection.content ".*from .* import .*")
  (#set! injection.include-children)
  (#set! injection.language "python"))
