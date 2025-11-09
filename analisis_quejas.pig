-- =========================================================
-- SCRIPT 1: ANALISIS DE QUEJAS EN RESENAS NEGATIVAS
-- =========================================================

-- 1. Cargar datos de resenas

raw_resenas = LOAD '/user/cloudera/repartos_rene/raw/resena' 
    USING PigStorage(',') 
    AS (resena_id:int, orden_transporte_id:int, puntuacion:int, comentario:chararray, fecha_calificacion:chararray);

-- 2. Filtrar por reseñas negativas (puntuacion 1 o 2) y que tengan comentarios reales (distinto de \N que usa Sqoop para nulls)
resenas_negativas = FILTER raw_resenas BY (puntuacion <= 2) AND (comentario != '\\N') AND (comentario is not null);

-- 3. Generar una 'bolsa' de palabras de cada comentario
-- TOKENIZE divide el texto en palabras. FLATTEN convierte esa lista en filas separadas.
palabras = FOREACH resenas_negativas GENERATE FLATTEN(TOKENIZE(comentario)) AS palabra;

-- 4. Limpieza opcional: convertir a minúsculas para unificar (requiere que 'palabra' sea chararray)
palabras_limpias = FOREACH palabras GENERATE LOWER(palabra) AS palabra_min;

-- 5. Agrupar por palabra idéntica
grupos_palabras = GROUP palabras_limpias BY palabra_min;

-- 6. Contar ocurrencias de cada palabra
conteo_palabras = FOREACH grupos_palabras GENERATE group AS palabra, COUNT(palabras_limpias) AS frecuencia;

-- 7. Ordenar por frecuencia descendente para ver los problemas más comunes primero
resultado_ordenado = ORDER conteo_palabras BY frecuencia DESC;

-- 8. Guardar el resultado en HDFS para análisis posterior
-- Borramos el directorio de salida si existe para evitar errores al re-ejecutar
rmf /user/cloudera/repartos_rene/processed/quejas_frecuentes
STORE resultado_ordenado INTO '/user/cloudera/repartos_rene/processed/quejas_frecuentes' USING PigStorage(',');