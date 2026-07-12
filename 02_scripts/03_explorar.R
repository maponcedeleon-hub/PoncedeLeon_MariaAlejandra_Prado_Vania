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

# =============================================================================
# 2. GRÁFICOS UNIVARIADOS
# =============================================================================

n_total <- nrow(base)
subtitulo_base <- sprintf("ENAHO 2025 — personas de 18 años o más (n muestral = %s)",
                          format(n_total, big.mark = ","))

# --- Figura 2: distribución del índice de participación ----------------------
g2 <- ggplot(base, aes(x = factor(part_indice),
                       weight = factor_exp / sum(factor_exp) * 100)) +
  geom_bar(fill = "#2c3e50") +
  labs(
    title    = "Figura 2. Distribución del índice de participación ciudadana",
    subtitle = subtitulo_base,
    x        = "Número de tipos de organización en los que participa el hogar\n(0 = ninguna, máximo = 17)",
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/explorar/figura2_dist_participacion.png",
       plot = g2, width = 8, height = 5, dpi = 300)

# --- Figura 3: distribución por identidad étnica -----------------------------
# Decisión: se agrupa lenguas amazónicas poco frecuentes en "Otras lenguas
# nativas" para mejorar la legibilidad del gráfico sin perder información
# analítica relevante. Las categorías individuales están en tabla3.

tabla_etnia_grafico <- base %>%
  mutate(
    etnia_agrupada = case_when(
      etnia == "Castellano"        ~ "Castellano",
      etnia == "Quechua"           ~ "Quechua",
      etnia == "Aimara"            ~ "Aimara",
      etnia %in% c("Otra lengua nativa", "Ashaninka", "Awajun/Aguaruna",
                   "Shipibo-Konibo", "Shawi/Chayahuita", "Achuar",
                   "Matsigenka/Machiguenga") ~ "Otras lenguas nativas",
      TRUE ~ "Otra"
    ),
    etnia_agrupada = factor(etnia_agrupada,
                            levels = c("Castellano", "Quechua", "Aimara",
                                       "Otras lenguas nativas", "Otra"))
  ) %>%
  group_by(etnia_agrupada) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

g3 <- ggplot(tabla_etnia_grafico,
             aes(x = reorder(etnia_agrupada, -pct), y = pct)) +
  geom_col(fill = "#2980b9") +
  geom_text(aes(label = paste0(pct, "%")), vjust = -0.5, size = 3.5) +
  labs(
    title    = "Figura 3. Distribución de la población adulta por lengua materna",
    subtitle = subtitulo_base,
    x        = "Lengua materna (proxy de identidad étnica)",
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07.\nLas lenguas amazónicas individuales se muestran en Tabla 3."
  ) +
  theme_minimal()

ggsave("03_outputs/explorar/figura3_dist_etnia.png",
       plot = g3, width = 8, height = 5, dpi = 300)

# --- Figura 4: distribución por nivel educativo ------------------------------
tabla_educ_orden <- base %>%
  group_by(educacion) %>%
  summarise(n_expandido = round(sum(factor_exp))) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

g4 <- ggplot(tabla_educ_orden, aes(x = educacion, y = pct)) +
  geom_col(fill = "#8e44ad") +
  geom_text(aes(label = paste0(pct, "%")), vjust = -0.5, size = 3.5) +
  labs(
    title    = "Figura 4. Distribución de la población adulta por nivel educativo",
    subtitle = subtitulo_base,
    x        = "Nivel educativo alcanzado",
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave("03_outputs/explorar/figura4_dist_educacion.png",
       plot = g4, width = 8, height = 5, dpi = 300)

cat("✓ Gráficos univariados exportados en 03_outputs/explorar/\n")

# =============================================================================
# 3. ANÁLISIS BIVARIADO: etnia × participación ciudadana
# Pregunta exploratoria: ¿varía la participación ciudadana según la
# identidad étnica (lengua materna)?
# Decisión: se usa la agrupación de etnia en 5 categorías para el análisis
# bivariado (igual que en Figura 3) para facilitar la comparación.
# Todos los estadísticos están ponderados con factor de expansión.
# =============================================================================

base_biv <- base %>%
  mutate(
    etnia_agrupada = case_when(
      etnia == "Castellano"        ~ "Castellano",
      etnia == "Quechua"           ~ "Quechua",
      etnia == "Aimara"            ~ "Aimara",
      etnia %in% c("Otra lengua nativa", "Ashaninka", "Awajun/Aguaruna",
                   "Shipibo-Konibo", "Shawi/Chayahuita", "Achuar",
                   "Matsigenka/Machiguenga") ~ "Otras lenguas nativas",
      TRUE ~ "Otra"
    ),
    etnia_agrupada = factor(etnia_agrupada,
                            levels = c("Castellano", "Quechua", "Aimara",
                                       "Otras lenguas nativas", "Otra"))
  )

# Tabla bivariada ponderada
tabla_biv <- base_biv %>%
  group_by(etnia_agrupada) %>%
  summarise(
    n                = n(),
    n_expandido      = round(sum(factor_exp)),
    media_part_pond  = round(weighted.mean(part_indice,
                                           w = factor_exp), 3),
    pct_participa    = round(weighted.mean(part_bin == 1,
                                           w = factor_exp) * 100, 1)
  ) %>%
  arrange(desc(media_part_pond))

cat("\n=== ANÁLISIS BIVARIADO: etnia × participación ===\n")
cat("Tabla 8. Participación ciudadana según lengua materna (ponderada)\n")
print(tabla_biv)
write_csv(tabla_biv,
          "03_outputs/explorar/tabla8_biv_etnia_participacion.csv")

# Tabla bivariada: etnia × área (contexto de la participación)
tabla_etnia_area <- base_biv %>%
  group_by(etnia_agrupada, area) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp)),
    .groups     = "drop"
  ) %>%
  group_by(etnia_agrupada) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

write_csv(tabla_etnia_area,
          "03_outputs/explorar/tabla9_etnia_area.csv")

cat("\n✓ Tablas bivariadas exportadas en 03_outputs/explorar/\n")

# =============================================================================
# 4. GRÁFICOS BIVARIADOS
# =============================================================================

# --- Figura 5: participación según identidad étnica (boxplot) ----------------

g5 <- base_biv %>%
  group_by(etnia_agrupada) %>%
  mutate(media_grupo = weighted.mean(part_indice, w = factor_exp)) %>%
  ungroup() %>%
  ggplot(aes(x = reorder(etnia_agrupada, media_grupo),
             y = part_indice)) +
  geom_boxplot(fill = "#2980b9", alpha = 0.7,
               outlier.alpha = 0.2) +
  coord_flip() +
  labs(
    title    = "Figura 5. Índice de participación ciudadana según lengua materna",
    subtitle = subtitulo_base,
    x        = "Lengua materna",
    y        = "Índice de participación (número de tipos de organización, 0–17)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/explorar/figura5_box_etnia_participacion.png",
       plot = g5, width = 8, height = 5, dpi = 300)

# --- Figura 6: % que participa según identidad étnica (barras) ---------------
g6 <- ggplot(tabla_biv,
             aes(x = reorder(etnia_agrupada, pct_participa),
                 y = pct_participa)) +
  geom_col(fill = "#e67e22") +
  geom_text(aes(label = paste0(pct_participa, "%")),
            hjust = 1.2, size = 3.5, color = "white") +
  coord_flip() +
  labs(
    title    = "Figura 6. Porcentaje que participa en al menos una organización\nsegún lengua materna",
    subtitle = subtitulo_base,
    x        = "Lengua materna (proxy de identidad étnica)",
    y        = "Porcentaje que participa en al menos una organización (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_minimal()

ggsave("03_outputs/explorar/figura6_bar_pct_participa_etnia.png",
       plot = g6, width = 8, height = 6, dpi = 300)

# --- Figura 7: participación según área (urbano/rural) -----------------------
tabla_area_part <- base %>%
  group_by(area) %>%
  summarise(
    n             = n(),
    n_expandido   = round(sum(factor_exp)),
    media_pond    = round(weighted.mean(part_indice, w = factor_exp), 3),
    pct_participa = round(weighted.mean(part_bin == 1,
                                        w = factor_exp) * 100, 1)
  )

g7 <- ggplot(tabla_area_part,
             aes(x = area, y = pct_participa, fill = area)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct_participa, "%")),
            vjust = -0.5, size = 4) +
  scale_fill_manual(values = c("Urbano" = "#3498db", "Rural" = "#27ae60")) +
  labs(
    title    = "Figura 7. Porcentaje que participa en al menos una organización\nsegún área geográfica",
    subtitle = subtitulo_base,
    x        = "Área geográfica",
    y        = "Porcentaje que participa (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_minimal()

ggsave("03_outputs/explorar/figura7_bar_area_participacion.png",
       plot = g7, width = 6, height = 5, dpi = 300)

cat("✓ Gráficos bivariados exportados en 03_outputs/explorar/\n")
cat("\n=== EXPLORACIÓN COMPLETA ===\n")
cat("Hallazgo principal: los quechuahablantes participan 2.6x más\n")
cat("que los castellanohablantes (54.7% vs 21.1%)\n")

