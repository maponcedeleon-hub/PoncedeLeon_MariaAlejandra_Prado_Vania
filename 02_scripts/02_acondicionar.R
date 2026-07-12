# =============================================================================
# Script 02: ACONDICIONAR — De datos crudos a datos listos para analizar
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   1. Se seleccionan 6 variables analíticas + identificadores + factor de expansión
#   2. Se renombran las variables con nombres legibles (ver sección 2)
#   3. Se corrigen los tipos de dato importados incorrectamente
#   4. Se diagnostican y gestionan los valores perdidos
#   5. Se filtra a mayores de 18 años (ciudadanos con derecho a participación)
#   6. Se exporta la base acondicionada para EXPLORAR y CLASIFICAR
# =============================================================================

library(tidyverse)
library(skimr)

# =============================================================================
# 1. CARGAR BASE UNIDA Y CHEQUEAR ESTRUCTURA
# =============================================================================

base <- read_csv("01_datos/procesados/base_unida.csv",
                 show_col_types = FALSE)

# Chequeo inicial de estructura
cat("=== ESTRUCTURA INICIAL ===\n")
cat(sprintf("Filas: %d | Columnas: %d\n", nrow(base), ncol(base)))
cat("\nTipos de variable:\n")
glimpse(base)

# =============================================================================
# 2. SELECCIÓN Y RENOMBRADO DE VARIABLES
# Decisión: se seleccionan 6 variables analíticas + identificadores +
#           factor de expansión. Las variables P801_* se descartan porque
#           ya están resumidas en indice_participacion y participa_binario.
# Criterio de selección:
#   - etnia (P300A): variable independiente principal (proxy de identidad étnica)
#   - part_indice: variable dependiente (participación ciudadana)
#   - educacion (P301A): control — la literatura señala que la educación
#     aumenta la participación cívica independientemente de la etnia
#   - sexo (P207): control — diferencias de género en participación están
#     documentadas en el contexto peruano
#   - area (ESTRATO): control — la participación en organizaciones comunales
#     es estructuralmente distinta en contextos rurales vs. urbanos
#   - pobreza (POBREZA): control — la condición socioeconómica puede
#     confundir la relación entre etnia y participación
#   - factor_exp (FACTOR07): obligatorio para análisis ponderado
#     representativo a nivel nacional (ver ficha técnica, sección 3)
# =============================================================================

base_seleccion <- base %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,  # identificadores
    P300A,                                  # lengua materna (proxy étnico)
    indice_participacion,                   # índice de participación (0-17)
    participa_binario,                      # participa / no participa
    P301A,                                  # nivel educativo
    P207,                                   # sexo
    ESTRATO,                                # estrato (urbano/rural)
    POBREZA,                                # condición de pobreza
    FACTOR07                                # factor de expansión
  ) %>%
  rename(
    etnia        = P300A,
    part_indice  = indice_participacion,
    part_bin     = participa_binario,
    educacion    = P301A,
    sexo         = P207,
    area         = ESTRATO,
    pobreza      = POBREZA,
    factor_exp   = FACTOR07
  )

cat("=== VARIABLES SELECCIONADAS Y RENOMBRADAS ===\n")
cat(sprintf("Variables en base seleccionada: %d\n", ncol(base_seleccion)))
cat(sprintf("Observaciones: %d\n", nrow(base_seleccion)))
names(base_seleccion)

# =============================================================================
# 3. CORRECCIÓN DE TIPOS DE DATO
# Decisión: las variables categóricas importadas como numérico se convierten
#           a factor con etiquetas legibles.
# Problema detectado en glimpse(): etnia, educacion, sexo, area y pobreza
#           llegaron como <dbl> porque SPSS almacena categorías como números.
#           Si no se corrigen, R las tratará como variables continuas en
#           gráficos y modelos, produciendo resultados incorrectos.
# =============================================================================

base_tipada <- base_seleccion %>%
  mutate(
    
    # etnia: lengua materna como proxy de identidad étnica
    # Fuente de etiquetas: diccionario ENAHO 2025, variable P300A
    etnia = case_when(
      etnia == 1  ~ "Quechua",
      etnia == 2  ~ "Aimara",
      etnia == 3  ~ "Otra lengua nativa",
      etnia == 4  ~ "Castellano",
      etnia == 10 ~ "Ashaninka",
      etnia == 11 ~ "Awajun/Aguaruna",
      etnia == 12 ~ "Shipibo-Konibo",
      etnia == 13 ~ "Shawi/Chayahuita",
      etnia == 14 ~ "Matsigenka/Machiguenga",
      etnia == 15 ~ "Achuar",
      TRUE        ~ "Otra"
    ),
    # Decisión: se agrupa en 5 categorías para el análisis:
    # castellano vs. lenguas indígenas (quechua, aimara, otras nativas amazónicas)
    etnia = factor(etnia,
                   levels = c("Castellano", "Quechua", "Aimara",
                              "Otra lengua nativa", "Ashaninka",
                              "Awajun/Aguaruna", "Shipibo-Konibo",
                              "Shawi/Chayahuita", "Matsigenka/Machiguenga",
                              "Achuar", "Otra")),
    
    # educacion: nivel educativo alcanzado
    # Fuente de etiquetas: diccionario ENAHO 2025, variable P301A
    educacion = case_when(
      educacion %in% 1:2 ~ "Sin nivel / Inicial",
      educacion %in% 3:4 ~ "Primaria",
      educacion %in% 5:6 ~ "Secundaria",
      educacion %in% 7:8 ~ "Superior no universitaria",
      educacion %in% 9:11 ~ "Superior universitaria o más",
      TRUE ~ NA_character_
    ),
    educacion = factor(educacion,
                       levels = c("Sin nivel / Inicial", "Primaria",
                                  "Secundaria", "Superior no universitaria",
                                  "Superior universitaria o más")),
    
    # sexo
    sexo = factor(if_else(sexo == 1, "Hombre", "Mujer")),
    
    # area: urbano/rural a partir del estrato
    # Decisión: estratos 1-6 = Urbano, estratos 7-8 = Rural
    # Fuente: metodología ENAHO, clasificación de estratos del INEI
    area = factor(if_else(area %in% 7:8, "Rural", "Urbano"),
                  levels = c("Urbano", "Rural")),
    
    # pobreza
    pobreza = factor(case_when(
      pobreza == 1 ~ "Pobre extremo",
      pobreza == 2 ~ "Pobre no extremo",
      pobreza == 3 ~ "No pobre"
    ),
    levels = c("Pobre extremo", "Pobre no extremo", "No pobre"))
  )

cat("=== TIPOS CORREGIDOS ===\n")
glimpse(base_tipada)

# =============================================================================
# 4. DIAGNÓSTICO DE VALORES PERDIDOS
# Siguiendo la taxonomía MCAR/MAR/MNAR:
#   - MCAR: ausencia completamente aleatoria → listwise deletion sin sesgo
#   - MAR: ausencia predecible por otras variables → imputación múltiple
#   - MNAR: ausencia relacionada con el valor no observado 
# =============================================================================

# Conteo y porcentaje de NAs por variable
reporte_nas <- base_tipada %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(),
               names_to  = "variable",
               values_to = "n_na") %>%
  mutate(
    total  = nrow(base_tipada),
    pct_na = round(n_na / total * 100, 2)
  ) %>%
  arrange(desc(n_na))

cat("=== REPORTE DE VALORES PERDIDOS ===\n")
print(reporte_nas)

# Gráfico de NAs
g_nas <- reporte_nas %>%
  filter(n_na > 0) %>%
  ggplot(aes(x = reorder(variable, pct_na), y = pct_na)) +
  geom_col(fill = "#c0392b") +
  geom_text(aes(label = paste0(pct_na, "%")),
            hjust = -0.2, size = 3.5) +
  coord_flip() +
  labs(
    title   = "Figura 1. Porcentaje de valores perdidos por variable",
    subtitle = "Base acondicionada — ENAHO 2025, personas mayores de 18 años",
    x       = NULL,
    y       = "Porcentaje de NAs (%)",
    caption = "Fuente: ENAHO 2025 - INEI. Elaboración propia."
  ) +
  theme_minimal()

ggsave("03_outputs/acondicionar/figura1_reporte_nas.png",
       plot = g_nas, width = 8, height = 5, dpi = 300)

write_csv(reporte_nas, "03_outputs/acondicionar/tabla1_reporte_nas.csv")

cat("\n✓ Reporte de NAs exportado en 03_outputs/acondicionar/\n")
