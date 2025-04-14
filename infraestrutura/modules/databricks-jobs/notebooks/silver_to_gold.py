# Notebook: Silver to Gold
# 
# Este notebook processa dados da camada Silver para a camada Gold,
# realizando agregações, cálculos e preparando dados para consumo.

# COMMAND ----------

# Configurações e importações
from pyspark.sql import functions as F
from pyspark.sql.types import *
import datetime

# COMMAND ----------

# Parâmetros
silver_path = "dbfs:/mnt/data/silver"
gold_path = "dbfs:/mnt/data/gold"
current_date = datetime.datetime.now().strftime("%Y-%m-%d")

# COMMAND ----------

# Leitura dos dados da camada Silver
print("Iniciando processamento Silver -> Gold")
df_silver = spark.read.format("delta").load(silver_path)

print(f"Registros na camada Silver: {df_silver.count()}")

# COMMAND ----------

# Agregações e transformações para a camada Gold

# Exemplo 1: Agregação por cliente
df_gold_cliente = df_silver.groupBy("cliente_id").agg(
    F.count("id_transacao").alias("total_transacoes"),
    F.sum("valor").alias("valor_total"),
    F.avg("valor").alias("valor_medio"),
    F.max("valor").alias("maior_transacao"),
    F.min("valor").alias("menor_transacao")
)

# Exemplo 2: Agregação por dia
df_gold_diario = df_silver.withColumn("data", F.to_date(F.col("timestamp"))) \
    .groupBy("data") \
    .agg(
        F.count("id_transacao").alias("total_transacoes"),
        F.sum("valor").alias("valor_total"),
        F.avg("valor").alias("valor_medio")
    )

# Exemplo 3: Estatísticas por tipo de transação
df_gold_tipo = df_silver.groupBy("tipo_transacao").agg(
    F.count("id_transacao").alias("total_transacoes"),
    F.sum("valor").alias("valor_total"),
    F.avg("valor").alias("valor_medio")
)

# COMMAND ----------

# Salvando datasets na camada Gold
df_gold_cliente.write.format("delta").mode("overwrite").save(f"{gold_path}/por_cliente")
df_gold_diario.write.format("delta").mode("overwrite").save(f"{gold_path}/por_dia")
df_gold_tipo.write.format("delta").mode("overwrite").save(f"{gold_path}/por_tipo")

print("Processamento Silver -> Gold concluído com sucesso!")
