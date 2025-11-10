#!/bin/bash

# (Opcional) variables para no repetir
HOST=192.168.1.8
PORT=5432
DB=repartos_rene
USER=admin
PASS=admin
BASE=/user/cloudera/repartos_rene/raw
HIVE_DB_NAME=repartos_rene

# Crear estructura base en HDFS
echo "Creando estructura base en HDFS..."
hdfs dfs -mkdir -p $BASE/{pais,region,ciudad,comuna,direccion,cliente,sucursal,repartidor,destinatario,ruta,ruta_pais,orden_transporte,resena,inconveniente}
if [ $? -ne 0 ]; then
  echo "Error al importar la tabla region."
fi


echo "Importando tabla pais..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table pais --target-dir $BASE/pais --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table pais > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla pais."
fi

echo "Importando tabla region..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table region --target-dir $BASE/region --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table region > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla region."
fi

echo "Importando tabla ciudad..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ciudad --target-dir $BASE/ciudad --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table ciudad > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla ciudad."
fi

echo "Importando tabla comuna..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table comuna --target-dir $BASE/comuna --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table comuna > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla comuna."
fi

echo "Importando tabla direccion..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table direccion --target-dir $BASE/direccion --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table direccion > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla direccion."
fi

echo "Importando tabla sucursal..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table sucursal --target-dir $BASE/sucursal --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table sucursal > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla sucursal."
fi

echo "Importando tabla repartidor..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table repartidor --target-dir $BASE/repartidor --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table repartidor > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla repartidor."
fi

echo "Importando tabla destinatario..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table destinatario --target-dir $BASE/destinatario --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table destinatario > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla destinatario."
fi

echo "Importando tabla ruta..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ruta --target-dir $BASE/ruta --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table ruta > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla ruta."
fi

echo "Importando tabla ruta_pais..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ruta_pais --target-dir $BASE/ruta_pais --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1 \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table ruta_pais > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla ruta_pais."
fi

## Tabla grandes (hechos): varios mappers, con split
# cliente
echo "Importando tabla cliente..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table cliente --target-dir $BASE/cliente --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by cliente_id \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table cliente > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla cliente."
fi

# orden_transporte
echo "Importando tabla orden_transporte..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table orden_transporte --target-dir $BASE/orden_transporte --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by orden_transporte_id \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table orden_transporte > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla orden_transporte."
fi

# resena
echo "Importando tabla resena..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table resena --target-dir $BASE/resena --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by resena_id \
  --hive-import --hive-database $HIVE_DB_NAME --hive-table resena > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla resena."
fi

# inconveniente
echo "Importando tabla inconveniente..."
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table inconveniente --target-dir $BASE/inconveniente --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by inconveniente_id > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error al importar la tabla inconveniente."
fi

echo "Script finalizado."
