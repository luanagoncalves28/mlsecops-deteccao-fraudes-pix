import os
import time
import datetime
import logging
from google.cloud import storage

# Configurando logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("backup-function")

def run_backup(request):
    """
    Função principal que realiza o backup de buckets GCS
    Args:
        request: HTTP request (não utilizado)
        
    Returns:
        Mensagem de sucesso ou erro
    """
    try:
        # Obter variáveis de ambiente
        source_buckets_str = os.environ.get('SOURCE_BUCKETS', '')
        dest_bucket = os.environ.get('DEST_BUCKET', '')
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        if not source_buckets_str or not dest_bucket:
            error_msg = "Erro: SOURCE_BUCKETS ou DEST_BUCKET não definidos nas variáveis de ambiente"
            logger.error(error_msg)
            return error_msg, 500
        
        # Inicializar cliente do Storage
        storage_client = storage.Client()
        
        # Criar timestamp para o backup
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # Lista de buckets fonte
        source_buckets = source_buckets_str.split(',')
        
        # Inicializar estatísticas
        total_files = 0
        total_bytes = 0
        
        # Processar cada bucket fonte
        for source_bucket_name in source_buckets:
            source_bucket_name = source_bucket_name.strip()
            
            try:
                source_bucket = storage_client.get_bucket(source_bucket_name)
                bucket_type = source_bucket_name.split('-')[-1]  # bronze, silver, gold
                
                logger.info(f"Iniciando backup do bucket: {source_bucket_name}")
                
                # Obter lista de blobs no bucket fonte
                blobs = list(source_bucket.list_blobs())
                
                if not blobs:
                    logger.info(f"Nenhum arquivo encontrado no bucket {source_bucket_name}")
                    continue
                
                # Inicializar bucket de destino
                dest_bucket_obj = storage_client.get_bucket(dest_bucket)
                
                # Backup de cada blob
                for blob in blobs:
                    # Definir o caminho de destino (mantendo a estrutura)
                    dest_path = f"{environment}/{bucket_type}/{timestamp}/{blob.name}"
                    
                    # Copiar o blob para o destino
                    logger.info(f"Copiando: {blob.name} para {dest_path}")
                    
                    source_bucket.copy_blob(
                        blob=blob,
                        destination_bucket=dest_bucket_obj,
                        new_name=dest_path
                    )
                    
                    # Atualizar estatísticas
                    total_files += 1
                    total_bytes += blob.size
            
            except Exception as e:
                logger.error(f"Erro ao processar bucket {source_bucket_name}: {str(e)}")
                continue
        
        # Gerar resumo do backup
        summary = {
            "timestamp": timestamp,
            "environment": environment,
            "buckets_processed": len(source_buckets),
            "files_backed_up": total_files,
            "total_bytes": total_bytes,
            "status": "success"
        }
        
        # Salvar resumo do backup
        dest_bucket_obj = storage_client.get_bucket(dest_bucket)
        summary_blob = dest_bucket_obj.blob(f"{environment}/summary/{timestamp}_backup_summary.json")
        summary_blob.upload_from_string(str(summary))
        
        logger.info(f"Backup concluído com sucesso. {total_files} arquivos ({total_bytes} bytes) copiados.")
        return f"Backup concluído com sucesso. {total_files} arquivos processados.", 200
    
    except Exception as e:
        error_msg = f"Erro durante o backup: {str(e)}"
        logger.error(error_msg)
        return error_msg, 500