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
