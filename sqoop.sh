# (Opcional) variables para no repetir
HOST=localhost
PORT=5432
DB=repartos_rene
USER=cloudera
PASS=cloudera
BASE=/user/cloudera/repartos_rene/raw

# Crear estructura base en HDFS
hdfs dfs -mkdir -p $BASE/{pais,region,ciudad,comuna,direccion,cliente,sucursal,repartidor,destinatario,ruta,ruta_pais,orden_transporte,resena,inconveniente}

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table pais --target-dir $BASE/pais --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table region --target-dir $BASE/region --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ciudad --target-dir $BASE/ciudad --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table comuna --target-dir $BASE/comuna --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table direccion --target-dir $BASE/direccion --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table sucursal --target-dir $BASE/sucursal --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table repartidor --target-dir $BASE/repartidor --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table destinatario --target-dir $BASE/destinatario --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ruta --target-dir $BASE/ruta --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table ruta_pais --target-dir $BASE/ruta_pais --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --num-mappers 1

## Tabla grandes (hechos): varios mappers, con split
# cliente
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table cliente --target-dir $BASE/cliente --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by cliente_id

# orden_transporte
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table orden_transporte --target-dir $BASE/orden_transporte --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by orden_transporte_id

# resena
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table resena --target-dir $BASE/resena --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by resena_id

# inconveniente
sqoop import --connect jdbc:postgresql://$HOST:$PORT/$DB --username $USER --password $PASS \
  --driver org.postgresql.Driver --table inconveniente --target-dir $BASE/inconveniente --delete-target-dir \
  --as-textfile --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' \
  --num-mappers 4 --split-by inconveniente_id
