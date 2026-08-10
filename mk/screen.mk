resolucao: ## mostra resolução da tela
	$(call log,$@)
	$(ADB_SHELL) wm size

screenshot: ## salva screenshot em screen.png
	$(call log,$@)
	@$(ADB) exec-out screencap -p > screen.png

screenrecord:
	$(call log,$@)
	@$(ADB_EXEC_OUT) screenrecord --output-format=h264 - > video.h264

video.mp4: video.h264
	$(call log,$@)
	$(FFMPEG) -i video.h264 video.mp4

live-screen:
	$(call log,$@)
	@$(ADB_EXEC_OUT) screenrecord  --output-format=h264 - | ffplay -

layout-bounds-on: ## ativa debug visual dos limites de layout
	$(call log,$@)
	@$(SETTINGS) put global debug_layout 1
	@$(SETTINGS) get global debug_layout
	@echo "Se não aparecer, reinicie com: make reboot"

layout-bounds-off: ## desativa debug visual dos limites de layout
	$(call log,$@)
	@$(SETTINGS) put global debug_layout 0
	@$(SETTINGS) get global debug_layout

# -----------------------------------------------------------------------------
# GESTOS -- navegação por gesto
# -----------------------------------------------------------------------------

kill-app: ## remove app atual da tela de recentes
	$(call log,$@)
	sleep 1
	$(SWIPE) 360 900 360 100 300

gesture-home: ## gesto de home (swipe curto de baixo para cima)
	$(call log,$@)
	$(SWIPE) 360 1382 360 800 200

gesture-recent-down: ## gesto longo para abrir recentes
	$(call log,$@)
	$(SWIPE) 360 1382 360 900 600

gesture-recent-up: ## gesto inverso em recentes
	$(call log,$@)
	$(SWIPE) 360 900 360 1382 600

gesture-back: ## gesto de voltar pela borda esquerda
	$(call log,$@)
	$(SWIPE) 0 800 300 800 150

# -----------------------------------------------------------------------------
# ACTIVITY / SETTINGS -- activity em foco e menus do sistema
# -----------------------------------------------------------------------------

current-activity: ## mostra a activity atual em foco
	$(call log,$@)
	@$(ADB_SHELL) dumpsys activity activities | grep -E 'mResumedActivity|topResumedActivity' | head -1

close-settings: ## fecha Configurações se estiver em foco
	$(call log,$@)
	@act="$$( $(ADB_SHELL) dumpsys activity activities | grep -E 'mResumedActivity|topResumedActivity' | head -1 )"; \
	echo "$$act"; \
	if echo "$$act" | grep -q 'com.android.settings'; then \
		echo "Configurações aberta. Fechando..."; \
		$(KEYEVENT) KEYCODE_BACK; \
		sleep 1; \
		$(KEYEVENT) KEYCODE_APP_SWITCH; \
		sleep 1; \
		$(SWIPE) 360 900 360 100 300; \
	else \
		echo "Configurações não está em foco."; \
	fi

wifi-settings: ## abre configurações de Wi-Fi
	$(call log,$@)
	@$(START) -a android.settings.WIFI_SETTINGS

developer-settings: ## abre opções de desenvolvedor
	$(call log,$@)
	@$(START) -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS

display-settings: ## abre configurações de tela
	$(call log,$@)
	@$(START) -a android.settings.DISPLAY_SETTINGS

sound-settings: ## abre configurações de som
	$(call log,$@)
	@$(START) -a android.settings.SOUND_SETTINGS

bluetooth-settings: ## abre configurações de Bluetooth
	$(call log,$@)
	@$(START) -a android.settings.BLUETOOTH_SETTINGS

security-settings: ## abre configurações de segurança
	$(call log,$@)
	@$(START) -a android.settings.SECURITY_SETTINGS

apps-settings: ## abre configurações de aplicativos
	$(call log,$@)
	@$(START) -a android.settings.APPLICATION_SETTINGS

