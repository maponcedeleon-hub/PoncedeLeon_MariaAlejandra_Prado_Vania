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
