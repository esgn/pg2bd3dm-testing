FROM debian:stable-slim

# Copie des scripts d'import de données 
WORKDIR /importer
COPY script.sh .

# Installation des dépendances
RUN apt update && \
    apt install --yes --no-install-recommends postgresql-client gdal-bin curl ca-certificates

CMD ["bash", "script.sh"]
