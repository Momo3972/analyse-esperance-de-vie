library(readr)
df <- read_csv("data/Life Expectancy Data.csv")

head(df)

str(df)

# 1. Analyse des valeurs manquantes
library(naniar)

# Nombre de NA par variable
miss_var_summary(df)

# Visualisation simple des NA
vis_miss(df)


# 2. Vérification et correction des types de variables
library(dplyr)

df <- df %>%
  mutate(
    Country = as.factor(Country),
    Status  = as.factor(Status),
    Year    = as.integer(Year)  # conserve Year en entier
  )

str(df)

# 3. Renommage propre des colonnes
# Certaines colonnes ont des espaces, des majuscules ou des noms peu pratiques pour coder.
# Ces colonnes vont être renommées en snake_case (standard propre en data science).

df <- df %>%
  rename(
    life_expectancy = `Life expectancy`,
    adult_mortality = `Adult Mortality`,
    infant_deaths = `infant deaths`,
    alcohol = `Alcohol`,
    percentage_expenditure = `percentage expenditure`,
    hepatitis_b = `Hepatitis B`,
    measles = `Measles`,
    bmi = `BMI`,
    under_five_deaths = `under-five deaths`,
    polio = `Polio`,
    total_expenditure = `Total expenditure`,
    diphtheria = `Diphtheria`,
    hiv_aids = `HIV/AIDS`,
    gdp = `GDP`,
    population = `Population`,
    thinness_1_19 = `thinness  1-19 years`,
    thinness_5_9 = `thinness 5-9 years`,
    income_composition = `Income composition of resources`,
    schooling = `Schooling`
  )

# Vérification
names(df)

# 4. Analyse exploratoire de base

# Statistiques descriptives globales
summary(df)

# Aperçu des valeurs les plus extrêmes
library(dplyr)

df %>%
  summarize(
    min_life = min(life_expectancy, na.rm = TRUE),
    max_life = max(life_expectancy, na.rm = TRUE),
    min_gdp = min(gdp, na.rm = TRUE),
    max_gdp = max(gdp, na.rm = TRUE),
    min_mort = min(adult_mortality, na.rm = TRUE),
    max_mort = max(adult_mortality, na.rm = TRUE)
  )

# 5. Visualisations exploratoires (corrélations et distributions)

# Cette étape vise à :
# - repérer les relations fortes entre variables,
# - visualiser la distribution de la variable cible,
# - détecter facilement outliers et patterns.

# 5.1 Matrice de corrélation

library(corrplot)

df_numeric <- df %>%
  select(where(is.numeric))

cor_mat <- cor(df_numeric, use = "pairwise.complete.obs")

corrplot(cor_mat, method = "color", type = "upper", tl.cex = 0.7)

# 5.2 Distribution de l'espérance de vie

library(ggplot2)

ggplot(df, aes(life_expectancy)) +
  geom_histogram(bins = 30, fill = "#4C72B0", color = "white") +
  labs(title = "Distribution de l'espérance de vie")

# 5.3 Life expectancy vs mortalité adulte

ggplot(df, aes(adult_mortality, life_expectancy)) +
  geom_point(alpha = 0.5) +
  labs(title = "Espérance de vie vs Mortalité adulte")

# 5.4 Comparaison par statut

ggplot(df, aes(Status, life_expectancy, fill = Status)) +
  geom_boxplot() +
  labs(title = "Espérance de vie selon le statut du pays")

# 5.5 PIB vs Espérance de vie

ggplot(df, aes(gdp, life_expectancy)) +
  geom_point(alpha = 0.5) +
  scale_x_log10() +
  labs(title = "Espérance de vie vs PIB (log scale)")

# 6. Nettoyage final : gestion des valeurs manquantes
# Objectif :
# - éliminer les NA problématiques,
# - imputer proprement ce qui peut l’être,
# - obtenir un dataset 100% exploitable pour la modélisation.

# 6.1 Vérification du nombre de NA par variable
library(naniar)
miss_var_summary(df)

# 6.2 Suppression des lignes où la life expectancy est manquante
# C’est la variable cible -> on ne peut pas l’imputer proprement

df <- df %>%
  filter(!is.na(life_expectancy))

# 6.3 Imputation simple pour les autres variables numériques (médiane)
df <- df %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

# 6.4 Vérifier qu'il n'y a plus de NA
sum(is.na(df))

# 7. Modélisation linéaire de base

# 7.1 Création des jeux train / test (80% / 20%)

set.seed(123)

n <- nrow(df)
train_idx <- sample(1:n, size = 0.8 * n)

train <- df[train_idx, ]
test  <- df[-train_idx, ]

nrow(train); nrow(test)

# 7.2 Définition et entraînement du modèle linéaire de base

formule_lm <- life_expectancy ~ adult_mortality + gdp + schooling +
  income_composition + hiv_aids + bmi + alcohol + Status + Year

modele_lm <- lm(formule_lm, data = train)

summary(modele_lm)

# 7.3 Évaluation du modèle (RMSE et R² sur train et test)

# Prédictions
pred_train <- predict(modele_lm, newdata = train)
pred_test  <- predict(modele_lm, newdata = test)

# Fonctions métriques
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2))
r2   <- function(y, yhat) 1 - sum((y - yhat)^2) / sum((y - mean(y))^2)

# Scores
rmse_train <- rmse(train$life_expectancy, pred_train)
rmse_test  <- rmse(test$life_expectancy,  pred_test)

r2_train <- r2(train$life_expectancy, pred_train)
r2_test  <- r2(test$life_expectancy,  pred_test)

rmse_train; rmse_test
r2_train; r2_test

# 7.4 Diagnostics du modèle (résidus, normalité, etc.)

par(mfrow = c(2, 2))
plot(modele_lm)
par(mfrow = c(1, 1))

# 7.5 - Représentation graphique du modèle (réel vs prédictions)

library(ggplot2)

# 7.5.1 Visualisation sur le train
ggplot(data.frame(
  reel = train$life_expectancy,
  predit = pred_train
), aes(x = reel, y = predit)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_abline(intercept = 0, slope = 1, color = "red", size = 1) +
  labs(
    title = "Train : Valeurs réelles vs prédictions",
    x = "Valeurs réelles",
    y = "Valeurs prédites"
  ) +
  theme_minimal()

# 7.5.2 Visualisation sur le test
ggplot(data.frame(
  reel = test$life_expectancy,
  predit = pred_test
), aes(x = reel, y = predit)) +
  geom_point(alpha = 0.5, color = "darkgreen") +
  geom_abline(intercept = 0, slope = 1, color = "red", size = 1) +
  labs(
    title = "Test : Valeurs réelles vs prédictions",
    x = "Valeurs réelles",
    y = "Valeurs prédites"
  ) +
  theme_minimal()

# 8 : Modélisation avancée
# Objectif : améliorer la performance et la robustesse du modèle

# 8.1 - Sélection de variables

# 8.1.1 Sélection de variables par AIC (stepwise)

library(MASS)

# On repart du même modèle complet que précédemment
modele_full <- lm(life_expectancy ~ adult_mortality + gdp + schooling +
                    income_composition + hiv_aids + bmi + alcohol +
                    Status + Year,
                  data = train)

# Stepwise (both directions)
modele_step <- stepAIC(modele_full, direction = "both", trace = FALSE)

summary(modele_step)

 ## Évaluation du modèle stepwise
# Prédictions
pred_train_step <- predict(modele_step, newdata = train)
pred_test_step  <- predict(modele_step, newdata = test)

# Scores
rmse_train_step <- rmse(train$life_expectancy, pred_train_step)
rmse_test_step  <- rmse(test$life_expectancy,  pred_test_step)

r2_train_step <- r2(train$life_expectancy, pred_train_step)
r2_test_step  <- r2(test$life_expectancy,  pred_test_step)

rmse_train_step; rmse_test_step
r2_train_step; r2_test_step

# 8.1.2 Sélection de variables par LASSO

library(glmnet)

# Construction des matrices de design (sans l'intercept)
formule_lasso <- life_expectancy ~ adult_mortality + gdp + schooling +
  income_composition + hiv_aids + bmi + alcohol + Status + Year

X_train <- model.matrix(formule_lasso, data = train)[, -1]
y_train <- train$life_expectancy

X_test  <- model.matrix(formule_lasso, data = test)[, -1]
y_test  <- test$life_expectancy

# Validation croisée pour choisir lambda
set.seed(123)
cv_lasso <- cv.glmnet(X_train, y_train, alpha = 1)

best_lambda <- cv_lasso$lambda.min
best_lambda

# Modèle LASSO final
modele_lasso <- glmnet(X_train, y_train, alpha = 1, lambda = best_lambda)

# Coefficients sélectionnés
coef(modele_lasso)

## Évaluation du LASSO
# Prédictions LASSO
pred_train_lasso <- as.numeric(predict(modele_lasso, newx = X_train))
pred_test_lasso  <- as.numeric(predict(modele_lasso, newx = X_test))

# Scores
rmse_train_lasso <- rmse(y_train, pred_train_lasso)
rmse_test_lasso  <- rmse(y_test,  pred_test_lasso)

r2_train_lasso <- r2(y_train, pred_train_lasso)
r2_test_lasso  <- r2(y_test,  pred_test_lasso)

rmse_train_lasso; rmse_test_lasso
r2_train_lasso; r2_test_lasso

# Récapitulatif des scores (tableau et viusualisation)
library(dplyr)

# Tableau récapitulatif des scores
resume_perf <- tibble(
  modele = c("Linéraire", "LASSO", "Stepwise AIC"),

  rmse_train = c(rmse_train, rmse_train_lasso, rmse_train_step),
  rmse_test  = c(rmse_test,  rmse_test_lasso,  rmse_test_step),

  r2_train   = c(r2_train,   r2_train_lasso,   r2_train_step),
  r2_test    = c(r2_test,    r2_test_lasso,    r2_test_step)
)

resume_perf

# Visualisation des performances
library(tidyr)
library(ggplot2)

resume_long <- resume_perf %>%
  pivot_longer(cols = -modele, names_to = "metrique", values_to = "valeur")

ggplot(resume_long, aes(x = modele, y = valeur, fill = modele)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ metrique, scales = "free_y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Comparaison des performances des modèles")

# 9. Importance des variables du modèle linéaire
library(dplyr)
library(ggplot2)
library(tidyr)

coeffs <- summary(modele_lm)$coefficients
coeffs_df <- as.data.frame(coeffs)
coeffs_df$variable <- rownames(coeffs_df)

# On enlève l'intercept
coeffs_df <- coeffs_df %>% filter(variable != "(Intercept)")

# Graphique
ggplot(coeffs_df, aes(x = reorder(variable, Estimate), y = Estimate)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Importance des variables dans le modèle linéaire",
    x = "Variable",
    y = "Coefficient estimé"
  )

# 10. Analyse avancée pour améliorer et mieux comprendre le modèle
# 10.1 Analyse approfondie des résidus
# Objectif : vérifier si le modèle linéaire viole les hypothèses :
# - linéarité
# - variance constante
# - normalité des résidus
# - absence d’outliers influents

library(ggplot2)

# Récupération des résidus
res <- resid(modele_lm)
fitted <- fitted(modele_lm)

# 1) Résidus vs valeurs ajustées
ggplot(data.frame(fitted, res), aes(fitted, res)) +
  geom_point(alpha = 0.4) +
  geom_hline(yintercept = 0, color = "red") +
  theme_minimal() +
  labs(title = "Résidus vs valeurs ajustées",
       x = "Valeurs ajustées",
       y = "Résidus")

# 2) QQ-Plot
ggplot(data.frame(res), aes(sample = res)) +
  stat_qq(alpha = 0.4) +
  stat_qq_line(color = "red") +
  theme_minimal() +
  labs(title = "QQ-plot des résidus")

# 3) Histogramme des résidus
ggplot(data.frame(res), aes(res)) +
  geom_histogram(bins = 40, fill = "steelblue", alpha = 0.7) +
  theme_minimal() +
  labs(title = "Distribution des résidus",
       x = "Résidus")

# 4) Détection des points influents
influence_vals <- cooks.distance(modele_lm)

ggplot(data.frame(index = 1:length(influence_vals),
                  cooks = influence_vals),
       aes(index, cooks)) +
  geom_bar(stat = "identity", fill = "tomato") +
  theme_minimal() +
  labs(title = "Distance de Cook",
       x = "Observation",
       y = "Cook's distance")

# 10.2 Analyse des interactions entre variables
# L’objectif est de tester si des relations du type variable1 × variable2 améliorent le modèle,
# en particulier entre variables fortement corrélées ou logiquement dépendantes

library(dplyr)

# Fonction utilitaire pour tester un modèle avec une interaction
test_interaction <- function(var1, var2) {
  formule <- as.formula(
    paste0("life_expectancy ~ adult_mortality + gdp + schooling + income_composition +
            hiv_aids + bmi + alcohol + population + Status + ",
           var1, " * ", var2)
  )

  modele <- lm(formule, data = train)

  pred_test <- predict(modele, newdata = test)

  rmse_val <- sqrt(mean((test$life_expectancy - pred_test)^2))
  r2_val   <- 1 - sum((test$life_expectancy - pred_test)^2) /
    sum((test$life_expectancy - mean(test$life_expectancy))^2)

  tibble(
    Interaction = paste(var1, "×", var2),
    RMSE_test = rmse_val,
    R2_test = r2_val
  )
}

# Liste des interactions à tester
interactions <- list(
  c("schooling", "income_composition"),
  c("adult_mortality", "hiv_aids"),
  c("gdp", "schooling"),
  c("population", "gdp"),
  c("Status", "income_composition"),
  c("bmi", "schooling")
)

# Tester toutes les interactions
resultats_interactions <- bind_rows(
  lapply(interactions, function(x) test_interaction(x[1], x[2]))
)

# Afficher les résultats
resultats_interactions

# 10.3 Comparaison avec un modèle non-linéaire (Random Forest)
# Objectif : Tester un modèle robuste, non linéaire, capable de capturer des interactions et des relations complexes sans les spécifier manuellement.

library(randomForest)

set.seed(123)

# 1. Construire des versions train/test SANS la variable Country
train_rf <- train[ , !(names(train) %in% c("Country")) ]
test_rf  <- test[  , !(names(test)  %in% c("Country")) ]

# Vérification rapide
names(train_rf)
# Country ne doit plus apparaître

# 2. Entraînement du Random Forest
modele_rf <- randomForest(
  life_expectancy ~ .,
  data = train_rf,
  ntree = 500,
  mtry = 4,
  importance = TRUE
)

# 3. Prédictions
pred_train_rf <- predict(modele_rf, newdata = train_rf)
pred_test_rf  <- predict(modele_rf, newdata = test_rf)

# 4. Métriques
rmse_rf_train <- sqrt(mean((train_rf$life_expectancy - pred_train_rf)^2))
rmse_rf_test  <- sqrt(mean((test_rf$life_expectancy  - pred_test_rf)^2))

r2_rf_train <- 1 - sum((train_rf$life_expectancy - pred_train_rf)^2) /
  sum((train_rf$life_expectancy - mean(train_rf$life_expectancy))^2)

r2_rf_test <- 1 - sum((test_rf$life_expectancy - pred_test_rf)^2) /
  sum((test_rf$life_expectancy - mean(test_rf$life_expectancy))^2)

rmse_rf_train; rmse_rf_test
r2_rf_train; r2_rf_test

# 5. Importance des variables
varImpPlot(modele_rf, main = "Importance des variables - Random Forest")

# 11. Comparaison finale des modèles
# 11.1 Tableau comparatif global (RMSE et R²)

library(tibble)

comparaison_finale <- tibble(
  Model = c("Régression linéaire", "Lasso", "Stepwise", "Random Forest"),
  RMSE_Train = c(rmse_train, rmse_train_lasso, rmse_train_step, rmse_rf_train),
  RMSE_Test  = c(rmse_test, rmse_test_lasso, rmse_test_step, rmse_rf_test),
  R2_Train   = c(r2_train, r2_train_lasso, r2_train_step, r2_rf_train),
  R2_Test    = c(r2_test, r2_test_lasso, r2_test_step, r2_rf_test)
)

print(comparaison_finale)

## Visualisation
library(ggplot2)
library(tidyr)

comparaison_long <- comparaison_finale %>%
  pivot_longer(cols = -Model, names_to = "Metric", values_to = "Value")

ggplot(comparaison_long, aes(x = Model, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Comparaison des performances des modèles",
       y = "Valeur", x = "Modèle")


# 11.2 Conclusion globale et variables explicatives clés

# 11.2.1 Rappel du meilleur modèle (sur RMSE_Test)
comparaison_finale
modele_gagnant <- comparaison_finale[which.min(comparaison_finale$RMSE_Test), ]
modele_gagnant

# 11.2.2 Variables les plus importantes dans le modèle linéaire
coeffs <- as.data.frame(summary(modele_lm)$coefficients)
coeffs$Variable <- rownames(coeffs)
coeffs$Importance <- abs(coeffs$Estimate)

coeffs_no_intercept <- coeffs[coeffs$Variable != "(Intercept)", ]
coeffs_ord <- coeffs_no_intercept[order(-coeffs_no_intercept$Importance), ]

top_lm <- head(coeffs_ord[, c("Variable", "Estimate", "Pr(>|t|)", "Importance")], 10)
top_lm

# 11.2.3 Variables importantes dans le Random Forest
imp_rf <- as.data.frame(importance(modele_rf))
imp_rf$Variable <- rownames(imp_rf)
imp_rf_ord <- imp_rf[order(-imp_rf[,"%IncMSE"]), ]

top_rf <- head(imp_rf_ord[, c("Variable", "%IncMSE", "IncNodePurity")], 10)
top_rf

# 11.2.4 Résumé texte final
cat("\n========== Synthèse 11.2 ==========\n")
cat("• Modèle gagnant (RMSE_Test minimal) :", as.character(modele_gagnant$Model), "\n")
cat("• Performances du Random Forest :\n",
    "   RMSE_Train =", round(rmse_rf_train, 3),
    "| RMSE_Test =", round(rmse_rf_test, 3), "\n",
    "   R2_Train  =", round(r2_rf_train, 3),
    "| R2_Test  =", round(r2_rf_test, 3), "\n\n")

cat("Top 10 variables (modèle linéaire) :\n")
print(top_lm)

cat("\nTop 10 variables (Random Forest, %IncMSE) :\n")
print(top_rf)
cat("=====================================\n\n")


# 11.3 Sauvegarde des résultats et objets importants

# 11.3.1 Création du dossier de sortie
dir.create("outputs", showWarnings = FALSE)

# 11.3.2 Sauvegarde de la comparaison des modèles
write.csv(comparaison_finale,
          file = "outputs/comparaison_modeles.csv",
          row.names = FALSE)

# 11.3.3 Sauvegarde des tables d'importance des variables
write.csv(top_lm,
          file = "outputs/importance_variables_lm.csv",
          row.names = FALSE)

write.csv(top_rf,
          file = "outputs/importance_variables_rf.csv",
          row.names = FALSE)

# 11.3.4 Sauvegarde des modèles entraînés
saveRDS(modele_lm, file = "outputs/modele_lineaire.rds")
saveRDS(modele_rf, file = "outputs/modele_random_forest.rds")

# 11.3.5 Sauvegarde des prédictions Random Forest sur le test
predictions_rf_test <- data.frame(
  Country = test$Country,
  Year = test$Year,
  life_expectancy_reelle  = test$life_expectancy,
  life_expectancy_predite = pred_test_rf
)

write.csv(predictions_rf_test,
          file = "outputs/predictions_random_forest_test.csv",
          row.names = FALSE)

cat("Les résultats, modèles et prédictions ont été sauvegardés dans 'outputs/'.\n")

# Générer le rapport final complet au format Word

library(rmarkdown)
render(
  input        = "rapport_final.Rmd",
  output_format = "word_document",
  output_file   = "rapport_final.docx",
  output_dir    = "outputs"
)
