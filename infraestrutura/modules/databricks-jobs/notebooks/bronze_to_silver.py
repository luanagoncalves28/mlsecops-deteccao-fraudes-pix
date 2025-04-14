# Notebook: Bronze to Silver
# 
# Este notebook processa dados da camada Bronze para a camada Silver,
# realizando validação, limpeza e transformações iniciais.

# COMMAND ----------

# Configurações e importações
from pyspark.sql import functions as F
from pyspark.sql.types import *
import datetime

# COMMAND ----------

# Parâmetros
bronze_path = "dbfs:/mnt/data/bronze"
silver_path = "dbfs:/mnt/data/silver"
current_date = datetime.datetime.now().strftime("%Y-%m-%d")

# COMMAND ----------

# Leitura dos dados da camada Bronze
print("Iniciando processamento Bronze -> Silver")
df_bronze = spark.read.format("delta").load(bronze_path)

print(f"Registros na camada Bronze: {df_bronze.count()}")

# COMMAND ----------

# Validação e limpeza de dados
df_silver = df_bronze.filter(
    (F.col("valor").isNotNull()) &
    (F.col("chave_pix").isNotNull()) &
    (F.col("timestamp").isNotNull())
)

# Enriquecimento com metadados e limpeza
df_silver = df_silver.withColumn("data_processamento", F.lit(current_date))
df_silver = df_silver.withColumn("valor", F.abs(F.col("valor")))  # Garantindo valores positivos
df_silver = df_silver.dropDuplicates(["id_transacao"])  # Removendo possíveis duplicatas

print(f"Registros válidos para camada Silver: {df_silver.count()}")

# COMMAND ----------

# Salvando na camada Silver
df_silver.write.format("delta").mode("overwrite").save(silver_path)

print("Processamento Bronze -> Silver concluído com sucesso!")
