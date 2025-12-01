# 02_generate_report.R
# Script pour générer automatiquement le rapport Word

# Assurer que le projet se situe ici
proj_root <- rprojroot::find_root(rprojroot::has_file("analyse-esperance-de-vie.Rproj"))
setwd(proj_root)

# Charger rmarkdown
library(rmarkdown)

# Générer le rapport
render(
  input        = "rapport_final.Rmd",
  output_format = "word_document",
  output_file   = "rapport_final.docx",
  output_dir    = "outputs",
  clean = TRUE,
  quiet = FALSE
)

cat("\n✔ Rapport généré dans outputs/rapport_final.docx\n")
