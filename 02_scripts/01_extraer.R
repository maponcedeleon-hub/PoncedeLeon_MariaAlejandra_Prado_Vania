# =============================================================================
# Script 01: EXTRAER — Carga y unión de módulos ENAHO 2025
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   1. Se usan 4 módulos de la ENAHO 2025: Sumaria, 300, 800A y 800B
#   2. La unión entre módulos se hace por las llaves oficiales del INEI:
#      CONGLOME + VIVIENDA + HOGAR (nivel hogar) y + CODPERSO (nivel persona)
#   3. Se usa left_join para conservar todos los casos del módulo 300
#      (personas), incluso si no tienen registro en 800B (solo tienen
#      registro quienes participan en alguna organización)
#   4. Se exporta la base unida sin modificaciones para preservar el dato
#      crudo. Toda limpieza ocurre en el script 02_acondicionar.R
# =============================================================================

library(tidyverse)
library(haven)