FROM php:8.4-apache

# Habilitando as extensões do PHP para conexão com o MySQL.
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilitando a extensão Rewrite do Apache para trabalhar com rotas.
RUN a2enmod rewrite


# O caminho é fixo: /var/www/html/
# O primeiro COPY copia a pasta com os arquivos do projeto.
# O segundo COPY copia o arquivo index.php.
# O terceiro COPY copia o arquivo .htaccess.
COPY ./App /var/www/html/App/
COPY ./index.php /var/www/html/
COPY ./.htaccess /var/www/html/

# Porta que o contêiner irá expor.
# A porta 80 é a porta padrão do Apache.
EXPOSE 80