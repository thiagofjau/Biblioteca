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

