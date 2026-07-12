# Instrucciones de descarga — Módulos ENAHO 2025

Los archivos de datos originales no están incluidos en este repositorio
por su tamaño y por restricciones de redistribución del INEI.

## Pasos para descargar

1. Ingresar a https://iinei.inei.gob.pe/microdatos/
2. Seleccionar **ENAHO** → año **2025**
3. Descargar los siguientes módulos en formato **.sav**:

| Archivo a descargar | Guardar como |
|---------------------|-------------|
| Sumaria | `Sumaria-2025-12g.sav` |
| Módulo 300 (Educación) | `Enaho01A-2025-300_Educacion.sav` |
| Módulo 800A (Gobernabilidad) | `Enaho01-2025-800A.sav` |
| Módulo 800B (Gobernabilidad) | `Enaho01-2025-800B.sav` |

4. Colocar los 4 archivos en esta carpeta (`01_datos/originales/`)
5. Ejecutar los scripts en orden desde RStudio

## Nota

Esta carpeta está incluida en `.gitignore` para evitar subir
archivos pesados al repositorio. Solo este archivo de instrucciones
está versionado.
