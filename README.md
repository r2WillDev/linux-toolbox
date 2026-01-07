# Linux Toolbox CLI 🛠️

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![ShellCheck](https://img.shields.io/badge/ShellCheck-Passing-success)
![Platform](https://img.shields.io/badge/Platform-Debian%20%7C%20Ubuntu-orange)

## 📖 Sobre
A **Linux Toolbox CLI** é um conjunto de utilitários de linha de comando (scripts Bash) projetados para facilitar a administração de sistemas, automação e diagnóstico em servidores Linux.
O projeto foca em **padronização** e **segurança**, fornecendo comandos intuitivos com prefixo `lxt-*` para tarefas rotineiras de DevOps.

## ⚙️ Pré-requisitos
O sistema requer um ambiente Linux padrão (base Debian/Ubuntu recomendada) com:
* **Bash** 4.0+
* Utilitários padrão: `tar`, `grep`, `ss`, `df`, `ps`
* Privilégios de **root** (sudo) para instalação global.

## 🚀 Instalação

### Instalação via Script (Recomendado)
Clone o repositório e execute o instalador:
```bash
cd linux-toolbox
sudo ./install.sh
```

### Desinstalação
Para remover a toolbox do sistema:
```bash
sudo ./uninstall.sh
```


## 💻 Guia de Uso

### 1. Verificação Básica
**Comando:** `lxt-hello`
```bash
$ lxt-hello
[LXT] Linux Toolbox is installed and working!
```

### 2. Backup Seguro
**Comando:** `lxt-backup`
```bash
# Sintaxe: lxt-backup -s <origem> -d <destino>
$ sudo lxt-backup -s /etc/nginx -d /backups
```

### 3. Análise de Disco
**Comando:** `lxt-disk`
```bash
$ lxt-disk /var/log
```

### 4. Busca Avançada
**Comando:** `lxt-find`
```bash
$ lxt-find -n "nginx.conf" -d /etc
$ lxt-find -e "log" -d /var
```

### 5. Inspeção de Portas
**Comando:** `lxt-ports`
```bash
$ lxt-ports       # Lista todas as portas ouvindo
$ lxt-ports 22    # Verifica apenas a porta 22
```

### 6. Monitoramento de Recursos
**Comando:** `lxt-proc`
```bash
$ lxt-proc cpu 5   # Top 5 consumidores de CPU
$ lxt-proc mem     # Top 10 consumidores de Memória
```


## 📂 Estrutura do Projeto

A organização dos diretórios segue o padrão Debian/Linux:

| Diretório | Descrição |
|-----------|-----------|
| `scripts/` | Código-fonte original das ferramentas (lxt-*). |
| `debian/` | Arquivos de metadados e estrutura para empacotamento .deb. |
| `docs/` | Documentação complementar e manuais. |
| `install.sh` | Script de automação de instalação. |

## 👨‍💻 Autor

Desenvolvido por **Arthur** (DevOps Intern).
Projeto prático para administração de sistemas e automação.

---
