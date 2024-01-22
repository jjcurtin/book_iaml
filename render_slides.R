# to render slides, the _quarto_revealjs.yml file  must be renamed to the default _quarto.yml, and then re-named back to allow the book to render with the "real" _quarto.yml. Using this function simplifies this pipeline

render_slides <- function(...) {
  file.rename("_quarto.yml", "_quarto_book.yml")
  file.rename("_quarto_revealjs.yml", "_quarto.yml")
  on.exit(file.rename("_quarto.yml", "_quarto_revealjs.yml"))
  on.exit(file.rename("_quarto_book.yml", "_quarto.yml"), add = TRUE)
  quarto::quarto_render(..., as_job = FALSE)
}