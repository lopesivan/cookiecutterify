# Configuração do repositório
NAME        = myapp
GITHUB_USER = lopesivan
REPO        = $(NAME)
REMOTE_REPO = ../$(NAME).tgz
LOCAL_REPO  = $(REPO)
REVISION    = 0.1
BRANCH      = main

# Cores para output
BOLD      := $(shell tput bold)
RESET     := $(shell tput sgr0)
BLUE      := $(shell tput setaf 4)
GREEN     := $(shell tput setaf 2)
YELLOW    := $(shell tput setaf 3)
RED       := $(shell tput setaf 1)
BG_BLUE   := $(shell tput setab 4)
BG_RED    := $(shell tput setab 1)

.DEFAULT_GOAL := help

.PHONY: help init git diff clean test status apply

##@ Informação

help: ## Mostra esta mensagem de ajuda
	@echo "$(BOLD)$(BLUE)Gerenciador de Patches Git$(RESET)"
	@echo "Repositório: $(GREEN)$(REMOTE_REPO)$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "$(BOLD)Uso:$(RESET)\n  make $(YELLOW)<target>$(RESET)\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Inicialização

init: git ## Clona o repositório e prepara para modificações
	@echo "$(BOLD)$(BG_BLUE) PRÓXIMOS PASSOS $(RESET)"
	@echo "1. Entre no diretório: $(GREEN)cd $(REPO)$(RESET)"
	@echo "2. Faça suas modificações"
	@echo "3. Commit as mudanças: $(GREEN)git add . && git commit -m 'suas mudanças'$(RESET)"
	@echo "4. Volte ao diretório pai: $(GREEN)cd ..$(RESET)"
	@echo "5. Gere o patch: $(BOLD)$(BG_RED) make diff $(RESET)"

git: ## Clona o repositório remoto
	@if [ -d "$(REPO)" ]; then \
		echo "$(YELLOW)⚠ Repositório $(REPO) já existe$(RESET)"; \
	else \
		echo "$(BLUE)→ Clonando $(REMOTE_REPO)...$(RESET)"; \
		tar xvzf $(REMOTE_REPO); \
		echo "$(GREEN)✓ Repositório clonado com sucesso$(RESET)"; \
	fi

##@ Geração de Patches
diff: $(REPO) ## Gera um patch com as modificações customizadas
	@echo "$(BLUE)→ Gerando patch...$(RESET)"
	@rm -rf a b
	@cp -r $(NAME) b
	@mkdir a
	@tar xzf $(REMOTE_REPO) -C a --strip-components=1
	@( \
	cd a; \
	git init -q; \
	git add -A; \
	git commit -q -m "baseline" --no-verify --allow-empty; \
	rsync -a --delete --exclude='.git' ../b/. .; \
	git add -A; \
	if git diff --cached --quiet; then \
		echo "$(YELLOW)⚠ Nenhuma modificação detectada$(RESET)"; \
		cd ..; rm -rf a b; \
		exit 1; \
	fi; \
	git commit -q -m "custom" --no-verify; \
	PATCH_NAME="$(REPO)-custom-$$(git log -n1 --format=format:'%h')-$$(date +%Y%m%d).patch"; \
	git format-patch --stdout HEAD^ >../$${PATCH_NAME}; \
	cd ..; \
	echo "$(GREEN)✓ Patch gerado: $${PATCH_NAME}$(RESET)"; \
	sha256sum $${PATCH_NAME} | tee sha256.txt; \
	echo "$(YELLOW)→ Execute 'make test' para testar o patch$(RESET)"; \
	)

##@ Testes e Aplicação

test: ## Testa a aplicação do patch gerado
	@echo "$(BLUE)→ Testando patch...$(RESET)"
	@PATCH_FILE=$$(ls -t *.patch 2>/dev/null | head -n1); \
	if [ -z "$$PATCH_FILE" ]; then \
		echo "$(RED)✗ Nenhum patch encontrado. Execute 'make diff' primeiro$(RESET)"; \
		exit 1; \
	fi; \
	echo "$(YELLOW)Testando: $$PATCH_FILE$(RESET)"; \
	git clone $(REMOTE_REPO) c 2>/dev/null; \
	cd c; \
	echo "$(BLUE)→ Estatísticas do patch:$(RESET)"; \
	git apply --stat ../$$PATCH_FILE; \
	echo "$(BLUE)→ Verificando patch:$(RESET)"; \
	git apply --check ../$$PATCH_FILE && \
	echo "$(GREEN)✓ Patch válido$(RESET)" || \
	(echo "$(RED)✗ Patch inválido$(RESET)"; exit 1); \
	echo "$(BLUE)→ Aplicando patch:$(RESET)"; \
	git am ../$$PATCH_FILE && \
	echo "$(GREEN)✓ Patch aplicado com sucesso$(RESET)" || \
	(echo "$(RED)✗ Falha ao aplicar patch$(RESET)"; exit 1)

apply: ## Aplica o último patch gerado em um repositório limpo
	@echo "$(BLUE)→ Aplicando patch em repositório limpo...$(RESET)"
	@PATCH_FILE=$$(ls -t *.patch 2>/dev/null | head -n1); \
	if [ -z "$$PATCH_FILE" ]; then \
		echo "$(RED)✗ Nenhum patch encontrado$(RESET)"; \
		exit 1; \
	fi; \
	if [ -d "$(REPO)-patched" ]; then \
		echo "$(RED)✗ Diretório $(REPO)-patched já existe$(RESET)"; \
		exit 1; \
	fi; \
	git clone $(REMOTE_REPO) $(REPO)-patched; \
	cd $(REPO)-patched; \
	git am ../$$PATCH_FILE && \
	echo "$(GREEN)✓ Patch aplicado em $(REPO)-patched$(RESET)"

status: ## Mostra o status atual dos patches e repositórios
	@echo "$(BOLD)$(BLUE)Status do Ambiente$(RESET)"
	@echo ""
	@echo "$(BOLD)Repositórios:$(RESET)"
	@for dir in $(REPO) a b c $(REPO)-patched; do \
		if [ -d "$$dir" ]; then \
			echo "  $(GREEN)✓$(RESET) $$dir"; \
		else \
			echo "  $(RED)✗$(RESET) $$dir"; \
		fi \
	done
	@echo ""
	@echo "$(BOLD)Patches disponíveis:$(RESET)"
	@if ls *.patch 1>/dev/null 2>&1; then \
		ls -lht *.patch | awk '{printf "  $(YELLOW)%s$(RESET) (%s)\n", $$9, $$5}'; \
	else \
		echo "  $(RED)Nenhum patch encontrado$(RESET)"; \
	fi
	@echo ""
	@if [ -f "sha256.txt" ]; then \
		echo "$(BOLD)Checksum:$(RESET)"; \
		cat sha256.txt | sed 's/^/  /'; \
	fi

##@ Limpeza

clean: ## Remove todos os repositórios temporários e patches
	@echo "$(RED)→ Limpando ambiente...$(RESET)"
	@rm -rf a b c $(REPO)-patched *.patch sha256.txt
	@echo "$(GREEN)✓ Ambiente limpo$(RESET)"

clean-all: clean ## Remove tudo, incluindo o repositório principal
	@echo "$(RED)→ Removendo repositório principal...$(RESET)"
	@rm -rf $(REPO)
	@echo "$(GREEN)✓ Tudo removido$(RESET)"

# eof
