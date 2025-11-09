# ======== VARS ========
HOST=localhost
PORT=3306
DB=repartos_rene
USER=cloudera
PASS=cloudera

JDBC_URL="jdbc:mysql://$HOST:$PORT/$DB?useSSL=false&serverTimezone=UTC"
DRIVER="com.mysql.cj.jdbc.Driver"

BASE=/user/cloudera/repartos_rene/raw
DELIM=,
NULLSTR='\\N'

# ======== HDFS: CARPETAS ========
hdfs dfs -mkdir -p $BASE/{pais,region,ciudad,comuna,direccion,cliente,sucursal,repartidor,destinatario,ruta,ruta_pais,orden_transporte,resena,inconveniente}

# ======== DIMENSIONES (1 mapper) ========
for T in pais region ciudad comuna direccion sucursal repartidor destinatario ruta ruta_pais; do
  sqoop import --connect "$JDBC_URL" --username $USER --password $PASS \
    --driver $DRIVER --table $T --target-dir $BASE/$T --delete-target-dir \
    --as-textfile --fields-terminated-by "$DELIM" --null-string "$NULLSTR" --null-non-string "$NULLSTR" \
    --num-mappers 1
done

# ======== TABLAS GRANDES (4 mappers + split-by PK) ========
sqoop import --connect "$JDBC_URL" --username $USER --password $PASS \
  --driver $DRIVER --table cliente --target-dir $BASE/cliente --delete-target-dir \
  --as-textfile --fields-terminated-by "$DELIM" --null-string "$NULLSTR" --null-non-string "$NULLSTR" \
  --num-mappers 4 --split-by cliente_id

sqoop import --connect "$JDBC_URL" --username $USER --password $PASS \
  --driver $DRIVER --table orden_transporte --target-dir $BASE/orden_transporte --delete-target-dir \
  --as-textfile --fields-terminated-by "$DELIM" --null-string "$NULLSTR" --null-non-string "$NULLSTR" \
  --num-mappers 4 --split-by orden_transporte_id

sqoop import --connect "$JDBC_URL" --username $USER --password $PASS \
  --driver $DRIVER --table resena --target-dir $BASE/resena --delete-target-dir \
  --as-textfile --fields-terminated-by "$DELIM" --null-string "$NULLSTR" --null-non-string "$NULLSTR" \
  --num-mappers 4 --split-by resena_id

sqoop import --connect "$JDBC_URL" --username $USER --password $PASS \
  --driver $DRIVER --table inconveniente --target-dir $BASE/inconveniente --delete-target-dir \
  --as-textfile --fields-terminated-by "$DELIM" --null-string "$NULLSTR" --null-non-string "$NULLSTR" \
  --num-mappers 4 --split-by inconveniente_id