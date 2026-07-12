# =============================================================================
# Script 03: EXPLORAR — Análisis exploratorio de datos (EDA)
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   1. Todo análisis descriptivo usa el factor de expansión (FACTOR07/factor_exp)
#      para que los resultados sean representativos a nivel nacional
#   2. Se exploran primero las distribuciones univariadas de cada variable
#   3. Luego se exploran las relaciones bivariadas entre etnia y participación
# =============================================================================

library(tidyverse)
library(skimr)

# -----------------------------------------------------------------------------
# Cargar base acondicionada
# -----------------------------------------------------------------------------

base <- read_csv("01_datos/procesados/base_acondicionada.csv",
                 show_col_types = FALSE) %>%
  mutate(
    etnia     = factor(etnia,
                       levels = c("Castellano", "Quechua", "Aimara",
                                  "Otra lengua nativa", "Ashaninka",
                                  "Awajun/Aguaruna", "Shipibo-Konibo",
                                  "Shawi/Chayahuita", "Matsigenka/Machiguenga",
                                  "Achuar", "Otra")),
    educacion = factor(educacion,
                       levels = c("Sin nivel / Inicial", "Primaria",
                                  "Secundaria", "Superior no universitaria",
                                  "Superior universitaria o más")),
    sexo      = factor(sexo, levels = c("Hombre", "Mujer")),
    area      = factor(area, levels = c("Urbano", "Rural")),
    pobreza   = factor(pobreza,
                       levels = c("Pobre extremo", "Pobre no extremo",
                                  "No pobre")),
    edad_grupo = factor(edad_grupo,
                        levels = c("18-29", "30-44", "45-59", "60 o más"))
  )

cat(sprintf("Base cargada: %d observaciones, %d variables\n",
            nrow(base), ncol(base)))

# =============================================================================
# 1. ANÁLISIS UNIVARIADO
# =============================================================================

# --- Variable dependiente: índice de participación (numérica) ----------------
cat("\n=== VARIABLE DEPENDIENTE: part_indice ===\n")

# Estadísticos ponderados
media_pond  <- weighted.mean(base$part_indice, w = base$factor_exp)
mediana_sim <- median(base$part_indice)

cat(sprintf("Media ponderada:    %.3f organizaciones\n", media_pond))
cat(sprintf("Mediana:            %.0f organizaciones\n", mediana_sim))
cat(sprintf("Máximo:             %.0f organizaciones\n", max(base$part_indice)))
cat(sprintf("Hogares sin participación: %.1f%%\n",
            weighted.mean(base$part_indice == 0,
                          w = base$factor_exp) * 100))

# Tabla de frecuencias ponderada
tabla_part <- base %>%
  group_by(part_indice) %>%
  summarise(
    n          = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct_expandido = round(n_expandido / sum(n_expandido) * 100, 1))

cat("\nTabla 2. Distribución del índice de participación (ponderada)\n")
print(tabla_part)
write_csv(tabla_part, "03_outputs/explorar/tabla2_dist_participacion.csv")

# --- Variable independiente: etnia (categórica) ------------------------------
cat("\n=== VARIABLE INDEPENDIENTE: etnia ===\n")

tabla_etnia <- base %>%
  group_by(etnia) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct_expandido = round(n_expandido / sum(n_expandido) * 100, 1)) %>%
  arrange(desc(n_expandido))

cat("\nTabla 3. Distribución por identidad étnica (ponderada)\n")
print(tabla_etnia)
write_csv(tabla_etnia, "03_outputs/explorar/tabla3_dist_etnia.csv")

# --- Variables de control ----------------------------------------------------
cat("\n=== VARIABLES DE CONTROL ===\n")

# Educación
tabla_educ <- base %>%
  group_by(educacion) %>%
  summarise(n = n(), n_expandido = round(sum(factor_exp))) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))
write_csv(tabla_educ, "03_outputs/explorar/tabla4_dist_educacion.csv")

# Sexo
tabla_sexo <- base %>%
  group_by(sexo) %>%
  summarise(n = n(), n_expandido = round(sum(factor_exp))) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))
write_csv(tabla_sexo, "03_outputs/explorar/tabla5_dist_sexo.csv")

# Área
tabla_area <- base %>%
  group_by(area) %>%
  summarise(n = n(), n_expandido = round(sum(factor_exp))) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))
write_csv(tabla_area, "03_outputs/explorar/tabla6_dist_area.csv")

# Pobreza
tabla_pobreza <- base %>%
  group_by(pobreza) %>%
  summarise(n = n(), n_expandido = round(sum(factor_exp))) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))
write_csv(tabla_pobreza, "03_outputs/explorar/tabla7_dist_pobreza.csv")

cat("✓ Tablas univariadas exportadas en 03_outputs/explorar/\n")
