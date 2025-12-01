# ==========================
# Makefile - pipeline projet
# ==========================

# 0) Variables générales
R_SCRIPT     = Rscript
SCRIPTS_DIR  = scripts
DATA_DIR     = data
OUTPUTS_DIR  = outputs

DATA_RAW     = $(DATA_DIR)/Life\ Expectancy\ Data.csv
DATA_CLEAN   = $(DATA_DIR)/life_expectancy_clean.csv

REPORT_RMD   = rapport_final.Rmd
REPORT_DOCX  = $(OUTPUTS_DIR)/rapport_final.docx

# 1) Règle par défaut : tout construire
all: $(REPORT_DOCX)

# 2) Étape 1 : nettoyage / modélisation (ton gros script)
#    On suppose que 01_import_cleaning.R :
#    - lit les données brutes
#    - fait le nettoyage + modèles
#    - sauvegarde les outputs dans /outputs
$(DATA_CLEAN): $(DATA_RAW) $(SCRIPTS_DIR)/01_import_cleaning.R
	$(R_SCRIPT) $(SCRIPTS_DIR)/01_import_cleaning.R

# 3) Étape 2 : génération du rapport Word
#    02_generate_report.R doit appeler rmarkdown::render(...)
$(REPORT_DOCX): $(REPORT_RMD) $(SCRIPTS_DIR)/02_generate_report.R $(DATA_CLEAN)
	$(R_SCRIPT) $(SCRIPTS_DIR)/02_generate_report.R

# 4) Nettoyage des fichiers générés
clean:
	# Supprimer les fichiers dérivés dans outputs/
	rm -f $(OUTPUTS_DIR)/*.csv
	rm -f $(OUTPUTS_DIR)/*.rds
	rm -f $(OUTPUTS_DIR)/rapport_final.docx

	# Supprimer les fichiers intermédiaires de knitr
	rm -f rapport_final.knit.md
	rm -f rapport_final.utf8.md

.PHONY: all clean