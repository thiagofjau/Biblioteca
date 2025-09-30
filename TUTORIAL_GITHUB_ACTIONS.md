# 🎓 **Tutorial Completo: Projeto Biblioteca com GitHub Actions**
*Do zero ao deploy automatizado - Passo a passo detalhado*

---

## 📋 **Pré-requisitos**
- [ ] Conta no GitHub
- [ ] Conta no Docker Hub
- [ ] Git instalado
- [ ] Docker Desktop instalado
- [ ] VS Code
- [ ] MySQL Workbench

---

## 🍴 **FASE 1: Fork e Clone do Projeto**

### **1.1 - Fazer Fork do Repositório do Professor**
1. Acesse: `https://github.com/tiagotas/biblioteca`
2. Clique no botão **"Fork"** (canto superior direito)
3. Escolha sua conta como destino
4. Clique **"Create fork"**
5. **Anote a URL do SEU fork:** `https://github.com/SEU-USUARIO/biblioteca`

### **1.2 - Clonar SEU Fork**
```bash
# Clone seu fork (IMPORTANTE: use sua URL!)
git clone https://github.com/SEU-USUARIO/biblioteca.git

# Entre na pasta
cd biblioteca

# Verifique se está no seu repositório
git remote -v
# Deve mostrar: origin https://github.com/SEU-USUARIO/biblioteca
```

---

## 📁 **FASE 2: Estrutura do Projeto e Arquivos**

### **2.1 - Analisar Estrutura Inicial**
```bash
# Veja a estrutura atual
ls -la
```

**Estrutura esperada:**
```
biblioteca/
├── App/                    # Código PHP da aplicação
│   ├── Controller/        # Controladores MVC
│   ├── DAO/              # Data Access Objects
│   ├── Model/            # Modelos de dados
│   ├── View/             # Views/Templates
│   ├── autoload.php      # Autoloader de classes
│   ├── config.php        # Configurações
│   ├── index.php         # Ponto de entrada da app
│   └── routes.php        # Rotas da aplicação
├── Modelagem/            # Scripts e modelagem do banco
│   ├── Projeto Fisico.sql # Script de criação das tabelas
│   ├── *.xml             # Arquivos de modelagem
│   └── *.jpg             # Diagramas
├── README.md             # Documentação
└── index.php             # Index principal
```

### **2.2 - Criar Arquivo .htaccess**
```bash
# Criar .htaccess na raiz
touch .htaccess
```

**Conteúdo do .htaccess:**
```apache
RewriteEngine On

# Redirecionar para pasta App se não for arquivo físico
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ App/index.php [QSA,L]

# Configurações de segurança
Options -Indexes

# Configurações PHP
php_value upload_max_filesize 10M
php_value post_max_size 10M
```

### **2.3 - Criar Dockerfile**
```bash
# Criar Dockerfile na raiz
touch Dockerfile
```

**Conteúdo do Dockerfile:**
```dockerfile
FROM php:8.1-apache

# Instalar extensões necessárias
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Copiar arquivos da aplicação
COPY . /var/www/html/

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# Configurar Apache para usar .htaccess
RUN echo '<Directory /var/www/html/>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/sites-available/000-default.conf

# Expor porta 80
EXPOSE 80
```

### **2.4 - Criar docker-compose.yml**
```bash
# Criar docker-compose.yml na raiz
touch docker-compose.yml
```

**Conteúdo do docker-compose.yml:**
```yaml
services:
  php:
    container_name: meu_servidor_php
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    depends_on:
      - mysql

  mysql:
    container_name: meu_servidor_mysql
    image: mysql:8.0
    restart: always
    environment:    
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: db_biblioteca
      MYSQL_USER: user
      MYSQL_PASSWORD: senha
    ports:
      - 3307:3306
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

---

## 🗄️ **FASE 3: Configuração do Banco de Dados**

### **3.1 - Editar Script SQL**
```bash
# Abrir arquivo SQL no VS Code
code Modelagem/Projeto\ Fisico.sql
```

### **3.2 - Padronizar Nomes para Minúsculas**

**⚠️ PROBLEMA ORIGINAL:**
```sql
-- Tinha tipos em maiúsculas e inconsistências
nome Varchar(255) not null,
data_nascimento Date not null,
cpf Char(11) not null,
```

**✅ CORREÇÃO - Converter tudo para minúsculas:**
```sql
-- Padronizar todos os tipos para minúsculas
nome varchar(255) not null,
data_nascimento date not null,
cpf char(11) not null,
```

**Script SQL Final Corrigido:**
```sql
CREATE TABLE autor (
id int auto_increment,
nome varchar(255) not null,
data_nascimento date not null,
cpf char(11) not null,
PRIMARY KEY(id)
);

CREATE TABLE categoria (
id int auto_increment,
descricao varchar(100) not null,
PRIMARY KEY (id)
);

CREATE TABLE livro (
id int auto_increment,
id_categoria int not null,
titulo varchar(255) not null,
editora varchar(150) not null,
ano year not null,
isbn varchar(100) not null,
PRIMARY KEY (id),
FOREIGN KEY (id_categoria) REFERENCES categoria(id)
);

CREATE TABLE aluno (
id int auto_increment,
nome varchar(150),
ra int,
curso varchar(150),
PRIMARY KEY(id)
);

CREATE TABLE usuario (
id int auto_increment,
nome varchar(150),
email varchar(150),
senha varchar(100),
PRIMARY KEY(id)
);

CREATE TABLE livro_autor_assoc (
id_livro int not null,
id_autor int not null,
FOREIGN KEY(id_livro) REFERENCES livro (id),
FOREIGN KEY(id_autor) REFERENCES autor (id),
PRIMARY KEY(id_livro, id_autor)
);

CREATE TABLE emprestimo (
id int auto_increment,
data_emprestimo date not null,
data_devolucao date not null,
id_usuario int not null,
id_aluno int not null,
id_livro int not null,
PRIMARY KEY(id),
FOREIGN KEY(id_usuario) REFERENCES usuario (id),
FOREIGN KEY(id_livro) REFERENCES livro (id),
FOREIGN KEY(id_aluno) REFERENCES aluno (id)
);
```

### **3.3 - Testar o Banco Localmente**
```bash
# Subir containers
docker compose up --build

# Em outro terminal, testar conexão
docker exec -it meu_servidor_mysql mysql -u root -p
# Senha: root
```

**No MySQL Workbench:**
- **Host:** localhost
- **Porta:** 3307
- **Usuário:** root
- **Senha:** root

---

## 🐳 **FASE 4: Configurar Docker Hub**

### **4.1 - Criar Conta Docker Hub**
1. Acesse: https://hub.docker.com/
2. Clique **"Sign Up"**
3. Crie sua conta
4. **Anote seu username** (ex: `tffjauds`)

### **4.2 - Gerar Access Token**
1. Login no Docker Hub
2. Avatar → **"Account Settings"**
3. **"Security"** → **"New Access Token"**
4. Nome: `GitHub Actions`
5. Permissões: **"Read, Write, Delete"**
6. **"Generate"**
7. **⚠️ COPIE O TOKEN:** `dckr_pat_XXXXXXXXX`

### **4.3 - Testar Login Local**
```bash
# Login local (para testar)
docker login -u SEU-USERNAME
# Cole o token quando pedir a senha
```

---

## 🔐 **FASE 5: Configurar Secrets no GitHub**

### **5.1 - Acessar SEU Repositório**
1. Vá em: `https://github.com/SEU-USUARIO/biblioteca`
2. **Settings** → **Secrets and variables** → **Actions**
3. **"New repository secret"**

### **5.2 - Criar Secrets**

**Secret 1:**
```
Name: DOCKERHUB_USERNAME
Secret: seu-usuario-dockerhub
```

**Secret 2:**
```
Name: DOCKERHUB_TOKEN
Secret: dckr_pat_XXXXXXXXXXXXXXXXX
```

**⚠️ IMPORTANTE:** 
- Use exatamente estes nomes
- Não inclua prefixos como "DOCKERHUB_TOKEN dckr_pat..."
- Apenas o valor puro

---

## 📁 **FASE 6: Criar GitHub Actions**

### **6.1 - Criar Estrutura**
```bash
# Criar pastas
mkdir -p .github/workflows

# Criar arquivo
touch .github/workflows/docker-build.yml
```

### **6.2 - Conteúdo do Workflow**
```yaml
name: Build and Push Docker Image

# Quando executar
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    # 1. Baixar código do repositório
    - name: Checkout repository
      uses: actions/checkout@v4
      
    # 2. Configurar Docker Buildx (ferramentas avançadas)
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    # 3. Login no Docker Hub usando secrets
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    # 4. Gerar tags automáticas para a imagem
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ secrets.DOCKERHUB_USERNAME }}/biblioteca
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
          
    # 5. Build da imagem e push para Docker Hub
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        file: ./Dockerfile
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

---

## 🚀 **FASE 7: Deploy e Commit**

### **7.1 - Verificar Arquivos Criados**
```bash
# Ver status dos arquivos
git status

# Deve mostrar:
# - .github/ (novo)
# - .htaccess (novo)
# - Dockerfile (novo)
# - docker-compose.yml (novo)
# - Modelagem/Projeto Fisico.sql (modificado)
```

### **7.2 - Commit Completo**
```bash
# Adicionar todos os arquivos
git add .

# Commit com mensagem descritiva
git commit -m "feat: add complete project structure with GitHub Actions

- Add .htaccess for Apache configuration
- Add Dockerfile for containerization
- Add docker-compose.yml for local development
- Add GitHub Actions workflow for Docker Hub deployment
- Update SQL script with lowercase field types
- Complete project structure ready for CI/CD"

# Push para SEU repositório
git push origin main
```

### **7.3 - Corrigir Remote se Necessário**
```bash
# Se estiver apontando para repo do professor:
git remote set-url origin https://github.com/SEU-USUARIO/biblioteca.git

# Verificar:
git remote -v
```

---

## 🔍 **FASE 8: Monitoramento e Testes**

### **8.1 - Acompanhar GitHub Actions**
1. Vá em: `https://github.com/SEU-USUARIO/biblioteca`
2. Clique na aba **"Actions"**
3. Veja o workflow **"Build and Push Docker Image"** executando
4. Clique nele para ver logs detalhados

### **8.2 - Verificar Resultado**
**✅ Sucesso:**
- Status verde no GitHub Actions
- Nova imagem em: `https://hub.docker.com/r/SEU-USERNAME/biblioteca`

**❌ Erro comum:**
```
Error: Username and password required
```
**Solução:** Verificar se secrets estão corretos

### **8.3 - Testar Imagem Gerada**
```bash
# Baixar sua imagem do Docker Hub
docker pull seu-username/biblioteca:latest

# Executar localmente
docker run -p 8080:80 seu-username/biblioteca:latest
```

---

## 📊 **FASE 9: Inserção de Dados de Teste**

### **9.1 - Scripts de INSERT Corrigidos**
```sql
-- Inserir dados de teste (usar aspas simples!)
INSERT INTO usuario (nome, email, senha) VALUES ('Admin', 'admin@biblioteca.com', SHA1('123'));

INSERT INTO categoria (descricao) VALUES ('Ficção');
INSERT INTO categoria (descricao) VALUES ('Técnico');

INSERT INTO autor (nome, data_nascimento, cpf) VALUES ('Machado de Assis', '1839-06-21', '12345678901');

INSERT INTO livro (id_categoria, titulo, editora, ano, isbn) VALUES 
(1, 'Dom Casmurro', 'Editora Ática', 1899, '978-85-08-12345-6');
```

### **9.2 - Problemas e Soluções**
**❌ Erro original:**
```sql
-- Estava com parênteses não fechado e aspas duplas
INSERT INTO usuario (nome, email, senha) VALUES ("Seu nome", "teste@teste.com", sha1('123');
```

**✅ Versão corrigida:**
```sql
-- Parênteses fechado, aspas simples, função maiúscula
INSERT INTO usuario (nome, email, senha) VALUES ('Seu nome', 'teste@teste.com', SHA1('123'));
```

---

## 🔄 **FASE 10: Fluxo de Desenvolvimento Contínuo**

### **10.1 - Workflow de Mudanças**
```bash
# 1. Fazer alterações no código
# ... editar arquivos ...

# 2. Testar localmente
docker compose up --build

# 3. Commit das mudanças
git add .
git commit -m "feat: nova funcionalidade X"
git push origin main

# 4. GitHub Actions executa automaticamente
# 5. Nova imagem é enviada para Docker Hub
```

### **10.2 - Tags Automáticas Geradas**
- `seu-username/biblioteca:latest` - sempre a mais recente
- `seu-username/biblioteca:main-a1b2c3d` - hash do commit
- `seu-username/biblioteca:pr-123` - para pull requests

---

## 🛠️ **TROUBLESHOOTING**

### **Problemas Comuns e Soluções**

**❌ MySQL não conecta:**
```bash
# Verificar se containers estão rodando
docker ps

# Logs do MySQL
docker logs meu_servidor_mysql

# Testar conexão
docker exec -it meu_servidor_mysql mysql -u root -proot
```

**❌ GitHub Actions falha no login:**
```
Error: Username and password required
```
**✅ Verificar:**
- Secrets configurados corretamente
- Nomes dos secrets: `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`
- Token ainda válido no Docker Hub

**❌ Build falha por Dockerfile:**
```
Error: Cannot locate specified Dockerfile
```
**✅ Verificar:**
- Dockerfile está na raiz do projeto
- Nome correto: `Dockerfile` (sem extensão)

---

## 📚 **Comandos de Referência**

```bash
# Git essencial
git status                    # Ver mudanças
git add .                     # Adicionar todos arquivos
git commit -m "mensagem"      # Commit
git push origin main          # Enviar para GitHub
git remote -v                 # Ver repositório configurado

# Docker local
docker compose up --build     # Subir containers com build
docker compose down           # Parar containers
docker ps                     # Ver containers rodando
docker logs CONTAINER_NAME    # Ver logs

# Docker Hub
docker login -u USERNAME      # Login
docker pull user/image:tag    # Baixar imagem
docker push user/image:tag    # Enviar imagem
```

---

## 🎯 **Checklist Final Completo**

### **Configuração Inicial:**
- [ ] Fork do repositório do professor
- [ ] Clone do SEU fork
- [ ] Estrutura de pastas verificada

### **Arquivos Criados/Editados:**
- [ ] `.htaccess` - configuração Apache
- [ ] `Dockerfile` - containerização
- [ ] `docker-compose.yml` - desenvolvimento local
- [ ] `Projeto Fisico.sql` - tipos em minúsculas
- [ ] `.github/workflows/docker-build.yml` - CI/CD

### **Docker Hub:**
- [ ] Conta criada
- [ ] Access token gerado
- [ ] Login local testado

### **GitHub:**
- [ ] Secrets configurados
- [ ] `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`
- [ ] Workflow executando com sucesso

### **Testes:**
- [ ] Build local funcionando
- [ ] MySQL conectando
- [ ] Imagem no Docker Hub
- [ ] GitHub Actions verde

---

**🎉 Parabéns! Você criou um pipeline completo de DevOps!**

*Agora a cada push, sua aplicação é automaticamente buildada, testada e enviada para o Docker Hub, pronta para deploy em qualquer lugar!* 🚀