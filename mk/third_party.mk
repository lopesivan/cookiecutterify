THIRD_PARTY_DIR := app/src/main/cpp/third_party

# Macro genérica para baixar e limpar repositórios
# $(1): URL do repositório
# $(2): Tag/Branch
# $(3): Diretório de destino
# $(4): Flags adicionais do git clone (opcional)
define clone_dep
	@mkdir -p $(THIRD_PARTY_DIR)
	@if [ ! -d "$(3)" ]; then \
		echo "Baixando $(notdir $(3)) ($(2))..."; \
		git clone --branch $(2) --depth 1 $(4) $(1) $(3); \
		rm -rf $(3)/.git $(3)/.gitignore $(3)/.gitlab-ci.yml $(3)/doc $(3)/.gitattributes $(3)/.github; \
	else \
		echo "Dependência $(notdir $(3)) já existe em $(3). Ignorando."; \
	fi
endef

.PHONY: deps fetch-raylib fetch-eigen fetch-yoga fetch-latexmath drop

deps: fetch-raylib fetch-eigen fetch-yoga fetch-latexmath ## 📦 Baixa todas as dependências de terceiros
	find $(THIRD_PARTY_DIR)/ -name ".git*" -print0  | xargs  -0 rm -rf

fetch-raylib: ## 📦 Baixa a raylib em third_party/raylib
	$(call log,$@)
	$(call clone_dep,https://github.com/raysan5/raylib.git,5.5,$(THIRD_PARTY_DIR)/raylib)

fetch-eigen: ## 📦 Baixa a eigen em third_party/eigen
	$(call log,$@)
	$(call clone_dep,https://gitlab.com/libeigen/eigen.git,3.4.0,$(THIRD_PARTY_DIR)/eigen)

fetch-yoga: ## 📦 Baixa a yoga em third_party/yoga_wrap
	$(call log,$@)
	$(call clone_dep,https://github.com/facebook/yoga.git,v3.1.0,$(THIRD_PARTY_DIR)/yoga_wrap)

fetch-latexmath: ## 📦 Baixa a AndroidLaTeXMath em third_party/AndroidLaTeXMath
	$(call log,$@)
	$(call clone_dep,https://github.com/NanoMichael/AndroidLaTeXMath.git,master,$(THIRD_PARTY_DIR)/AndroidLaTeXMath,--recursive)

drop: ## 🧹 Limpa todos os artefatos e bibliotecas de terceiros
	rm -rf $(THIRD_PARTY_DIR)
	git clean -dfx
