# Analyse de l'espérance de vie (2000–2015)

Ce projet étudie les facteurs influençant l’espérance de vie dans le monde à partir des données de l’OMS.  
Il repose sur une pipeline reproductible (`Makefile`), un nettoyage complet, des visualisations interprétées et une modélisation avancée (régression linéaire, LASSO, Stepwise, Random Forest).

---

## 📊 1. Visualisations principales et interprétations

### **1.1 Distribution de l’espérance de vie**
**Fig :** histogramme de `life_expectancy`.  
**Interprétation :**  
- La distribution est centrée autour de *70 ans*.  
- Quelques pays présentent une espérance de vie inférieure à 50 ans → indicateur de fragilité sanitaire.  
- Les valeurs supérieures à 80 ans concernent principalement des pays développés.

---

### **1.2 Relation entre mortalité adulte et espérance de vie**
**Fig :** scatterplot `adult_mortality` vs `life_expectancy`.  
**Interprétation :**  
- Relation *fortement décroissante* : plus la mortalité adulte est élevée, plus l’espérance de vie chute.  
- Le nuage de points densément structuré confirme `adult_mortality` comme variable explicative majeure.

---

### **1.3 Impact économique : PIB vs Espérance de vie**
**Fig :** scatterplot `GDP` vs `life_expectancy`.  
**Interprétation :**  
- Relation croissante mais non linéaire :  
  - Gains rapides d’espérance de vie pour les faibles niveaux de PIB.  
  - Effet marginal décroissant : après un certain seuil, augmenter le PIB n’améliore plus autant la santé.  
- Reflète la littérature économique (effet Preston Curve).

---

### **1.4 Corrélogramme (corrplot)**
**Interprétation :**  
- Variables les plus corrélées positivement à l’espérance de vie :  
  - `schooling`,  
  - `income_composition`,  
  - `BMI`.  
- Variables corrélées négativement :  
  - `adult_mortality`,  
  - `hiv_aids`,  
  - `infant_deaths`.  
- La matrice confirme les intuitions sanitaires : mortalité et maladies réduisent la durée de vie.

---

### **1.5 Boxplots : espérance de vie par statut de développement**
**Interprétation :**
- Les pays *developed* présentent systématiquement des espérances de vie plus élevées.  
- La variabilité est plus forte chez les pays *developing*, illustrant des inégalités internes.

---

### **1.6 Importance des variables – Modèle linéaire**
**Interprétation :**
Variables majeures :  
1. `income_composition` (contribution énorme et significative)  
2. `schooling`  
3. `hiv_aids` (effet négatif très fort)  
4. `adult_mortality`  

→ Ce modèle capture surtout les effets structurels : éducation, santé, richesse.

---

### **1.7 Importance des variables – Random Forest (%IncMSE)**
**Interprétation :**
Top 5 :  
1. `hiv_aids`  
2. `adult_mortality`  
3. `income_composition`  
4. `thinness_5_9`  
5. `Year`  

→ Le Random Forest détecte des effets non linéaires et des interactions complexes (notamment nutrition & charge sanitaire).

---

### **1.8 Comparaison des performances modèles**
| Modèle              | RMSE Test | R² Test |
|---------------------|-----------|---------|
| Régression linéaire | 4.47      | 0.786   |
| LASSO               | 4.47      | 0.786   |
| Stepwise            | 4.48      | 0.785   |
| **Random Forest**   | **1.91**  | **0.961** |

**Interprétation :**  
- Le Random Forest domine largement → capture d’interactions et non‑linéarités.  
- Les modèles linéaires restent interprétables mais moins performants.

---

## 🧹 2. Pipeline reproductible (Makefile)

```
make clean   # supprime outputs et fichiers intermédiaires
make         # exécute la pipeline : nettoyage + modèles + rapport
```

---

## 📁 3. Structure du projet

```
analyse-esperance-de-vie/
│
├── data/                     # Données brutes
├── outputs/                  # Résultats générés automatiquement
├── scripts/
│   ├── 01_import_cleaning.R  # Nettoyage + modèles
│   └── 02_generate_report.R  # Génération du rapport Word
├── rapport_final.Rmd         # Rapport complet
├── Makefile                  # Pipeline
└── README.md                 # Présent fichier
```

---

## 📝 4. Rapport final

Le rapport complet est généré automatiquement par :

```
make
```

Il est disponible dans :  
👉 `outputs/rapport_final.docx`

---

## 🎯 5. Conclusion générale

- Le modèle Random Forest fournit la meilleure précision.  
- L’espérance de vie dépend fortement :  
  - de la mortalité adulte,  
  - du niveau de santé (HIV, nutrition),  
  - du développement humain (éducation, revenu).  
- Le pipeline reproductible assure une maintenance et une réexécution immédiate du projet.

---

## 📬 Contact

Pour toute question : **Lamine (Momo)**  
Projet disponible sur GitHub : *analyse-esperance-de-vie*
