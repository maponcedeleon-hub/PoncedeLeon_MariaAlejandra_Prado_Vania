# =============================================================================
# Script 04: CLASIFICAR — Creación de variables analíticas
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   Se crean tres variables analíticas nuevas a partir de las exploradas en
#   el script 03.
#
#   Variable 1: indigena (dummy binaria)
#   Concepto: pertenencia a un grupo étnico indígena
#   Operacionalización: lengua materna indígena vs. castellano
#   Justificación del corte: la distinción indígena/no indígena es la
#     categoría analítica central en la literatura sobre ciudadanía étnica
#     en América Latina (Yashar, 2005; Van Cott, 2005; Sulmont, 2012).
#     El corte es teórico, no basado en datos, lo que permite comparabilidad
#     con otros estudios del campo.
#   Limitación: las lenguas amazónicas tienen muy baja frecuencia muestral
#     (n < 500 cada una), por lo que se agrupan con quechua y aimara bajo
#     la categoría "indígena". Esto implica asumir que comparten un patrón
#     de participación similar, supuesto que la exploración bivariada apoya
#     pero no confirma definitivamente.
#
#   Variable 2: nivel_participacion (ordinal, 3 categorías)
#   Concepto: intensidad de la participación ciudadana en organizaciones
#   Operacionalización: recodificación del índice part_indice en tres niveles
#   Justificación del corte:
#     - "Ninguna" (0): no participa en ninguna organización — categoría
#       sustantivamente distinta porque implica ausencia total de vínculos
#       organizacionales formales
#     - "Baja" (1–2): participación en una o dos organizaciones — nivel
#       típico de participación instrumental (ej. APAFA, vaso de leche)
#     - "Alta" (3 o más): participación en tres o más organizaciones — indica
#       un perfil de ciudadanía activa y múltiple vinculación comunitaria
#     Los cortes se basan en la distribución observada en EXPLORAR:
#     el 72.3% no participa, el 22.2% participa en una organización, y
#     solo el 5.4% en tres o más. El corte en 3 separa un grupo cuali-
#     tativamente distinto de alta participación.
#
#   Variable 3: participa_comunal (dummy)
#   Concepto: participación en organizaciones de base territorial/comunal
#   Operacionalización: 1 si el hogar participa en junta vecinal (P801_4),
#     ronda campesina (P801_5), comunidad campesina (P801_16) o presupuesto
#     participativo (P801_14)
#   Justificación: estas organizaciones son las más directamente vinculadas
#     a la ciudadanía local y a las formas tradicionales de organización
#     indígena en el Perú. Su análisis separado permite distinguir entre
#     participación genérica y participación político-territorial.
# =============================================================================

library(tidyverse)

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

cat(sprintf("Base cargada: %d observaciones\n", nrow(base)))

# =============================================================================
# 1. VARIABLE: indigena (dummy binaria)
# =============================================================================

base <- base %>%
  mutate(
    indigena = case_when(
      etnia == "Castellano" ~ 0L,
      etnia == "Otra"       ~ NA_integer_,  # categoría ambigua, se excluye
      TRUE                  ~ 1L            # todas las lenguas nativas
    ),
    indigena_label = factor(indigena,
                            levels = c(0, 1),
                            labels = c("No indígena", "Indígena"))
  )

# Distribución ponderada
dist_indigena <- base %>%
  filter(!is.na(indigena)) %>%
  group_by(indigena_label) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

cat("\n=== Variable 1: indigena ===\n")
cat("Regla: 1 = lengua materna indígena; 0 = castellano; NA = otra\n")
cat("Nota: 'Otra' (n=300) excluida por ambigüedad — no es lengua\n")
cat("      nativa ni castellano claramente\n\n")
print(dist_indigena)
write_csv(dist_indigena, "03_outputs/clasificar/tabla_dist_indigena.csv")

# Gráfico
g_indigena <- ggplot(dist_indigena,
                     aes(x = indigena_label, y = pct,
                         fill = indigena_label)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%\n(n expandido = ",
                               format(n_expandido, big.mark = ","), ")")),
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("No indígena" = "#2980b9",
                               "Indígena"    = "#e67e22")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title    = "Figura 8. Distribución de la variable 'indigena'",
    subtitle = "Recodificación binaria a partir de lengua materna — ENAHO 2025\n(n muestral = 75,922, excluyendo categoría 'Otra')",
    x        = NULL,
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/clasificar/figura8_dist_indigena.png",
       plot = g_indigena, width = 6, height = 5, dpi = 300)

cat("✓ Variable 'indigena' creada y exportada.\n")

# =============================================================================
# 2. VARIABLE: nivel_participacion 
# =============================================================================

base <- base %>%
  mutate(
    nivel_participacion = case_when(
      part_indice == 0              ~ "Ninguna",
      part_indice %in% 1:2          ~ "Baja",
      part_indice >= 3              ~ "Alta"
    ),
    nivel_participacion = factor(nivel_participacion,
                                 levels = c("Ninguna", "Baja", "Alta"))
  )

# Distribución ponderada
dist_nivel <- base %>%
  group_by(nivel_participacion) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

cat("\n=== Variable 2: nivel_participacion ===\n")
cat("Regla: Ninguna (0) / Baja (1-2 org.) / Alta (3+ org.)\n")
cat("Justificación del corte en 3: solo el 5.4% participa en 3+\n")
cat("organizaciones — grupo cualitativamente distinto de alta\n")
cat("participación cívica múltiple\n\n")
print(dist_nivel)
write_csv(dist_nivel,
          "03_outputs/clasificar/tabla_dist_nivel_participacion.csv")

# Gráfico
g_nivel <- ggplot(dist_nivel,
                  aes(x = nivel_participacion, y = pct,
                      fill = nivel_participacion)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%\n(n expandido = ",
                               format(n_expandido, big.mark = ","), ")")),
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("Ninguna" = "#c0392b",
                               "Baja"    = "#f39c12",
                               "Alta"    = "#27ae60")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title    = "Figura 9. Distribución de la variable 'nivel_participacion'",
    subtitle = sprintf("Recodificación ordinal del índice de participación — ENAHO 2025\n(n muestral = %s)",
                       format(nrow(base), big.mark = ",")),
    x        = "Nivel de participación ciudadana",
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/clasificar/figura9_dist_nivel_participacion.png",
       plot = g_nivel, width = 7, height = 5, dpi = 300)

cat("✓ Variable 'nivel_participacion' creada y exportada.\n")

# =============================================================================
# 3. VARIABLE: participa_comunal (dummy binaria)
# =============================================================================

# =============================================================================
# 3. VARIABLE: participa_comunal (dummy binaria)
# =============================================================================

# Recuperar variables P801 comunales de la base unida
base_unida <- read_csv("01_datos/procesados/base_unida.csv",
                       show_col_types = FALSE)

# Unir y crear variable en un solo paso para evitar pérdida de columnas
base <- base %>%
  left_join(
    base_unida %>%
      select(CONGLOME, VIVIENDA, HOGAR, CODPERSO,
             P801_4,   # junta vecinal
             P801_5,   # ronda campesina
             P801_14,  # presupuesto participativo
             P801_16), # comunidad campesina
    by = c("CONGLOME", "VIVIENDA", "HOGAR", "CODPERSO")
  ) %>%
  mutate(
    participa_comunal = if_else(
      P801_4 == 1 | P801_5 == 1 | P801_14 == 1 | P801_16 == 1,
      1L, 0L
    ),
    participa_comunal = replace_na(participa_comunal, 0L)
  )

dist_comunal <- base %>%
  group_by(participa_comunal) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(
    pct   = round(n_expandido / sum(n_expandido) * 100, 1),
    label = if_else(participa_comunal == 1,
                    "Participa en org. comunal",
                    "No participa en org. comunal")
  )

cat("\n=== Variable 3: participa_comunal ===\n")
cat("Regla: 1 = participa en junta vecinal, ronda campesina,\n")
cat("       presupuesto participativo o comunidad campesina\n")
cat("Justificación: organizaciones de base territorial vinculadas\n")
cat("a ciudadanía local y formas tradicionales de organización indígena\n\n")
print(dist_comunal)
write_csv(dist_comunal,
          "03_outputs/clasificar/tabla_dist_participa_comunal.csv")

# =============================================================================
# 4. TABLA CRUZADA: indigena × nivel_participacion (ponderada)
# =============================================================================

tabla_cruzada <- base %>%
  filter(!is.na(indigena_label)) %>%
  group_by(indigena_label, nivel_participacion) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp)),
    .groups     = "drop"
  ) %>%
  group_by(indigena_label) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1)) %>%
  ungroup()

cat("\n=== Tabla cruzada: indigena × nivel_participacion ===\n")
print(tabla_cruzada)
write_csv(tabla_cruzada,
          "03_outputs/clasificar/tabla_cruzada_indigena_participacion.csv")

# Gráfico tabla cruzada
g_cruzada <- ggplot(tabla_cruzada,
                    aes(x = nivel_participacion, y = pct,
                        fill = indigena_label)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0(pct, "%")),
            position = position_dodge(width = 0.9),
            vjust = -0.5, size = 3.2) +
  scale_fill_manual(values = c("No indígena" = "#2980b9",
                               "Indígena"    = "#e67e22")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title    = "Figura 10. Nivel de participación ciudadana según identidad étnica",
    subtitle = sprintf("Comparación ponderada — ENAHO 2025 (n muestral = %s)",
                       format(nrow(base %>% filter(!is.na(indigena_label))),
                              big.mark = ",")),
    x        = "Nivel de participación ciudadana",
    y        = "Porcentaje dentro de cada grupo étnico (%)",
    fill     = "Identidad étnica",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/clasificar/figura10_cruzada_indigena_participacion.png",
       plot = g_cruzada, width = 8, height = 5, dpi = 300)

# =============================================================================
# 5. EXPORTAR BASE FINAL
# =============================================================================

base_final <- base %>%
  select(CONGLOME, VIVIENDA, HOGAR, CODPERSO,
         etnia, indigena, indigena_label,
         part_indice, part_bin,
         nivel_participacion, participa_comunal,
         educacion, sexo, area, pobreza, edad_grupo,
         factor_exp)

write_csv(base_final, "01_datos/procesados/base_final.csv")

cat("\n✓ Base final exportada.\n")
cat(sprintf("  Observaciones: %d\n", nrow(base_final)))
cat(sprintf("  Variables: %d\n", ncol(base_final)))
cat("\nResumen de variables analíticas creadas:\n")
cat("  1. indigena: dummy (0=No indígena, 1=Indígena, NA=Otra)\n")
cat("  2. nivel_participacion: ordinal (Ninguna/Baja/Alta)\n")
cat("  3. participa_comunal: dummy (0=No, 1=Sí)\n")
