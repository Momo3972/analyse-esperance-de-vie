library(rmarkdown)

render(
  input       = "rapport_final.Rmd",          # Rmd à la racine du projet
  output_file = "outputs/rapport_final.docx", # fichier Word dans outputs/
  envir       = new.env()                     # environnement propre
)
