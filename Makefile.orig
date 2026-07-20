MY_GRADLE_LOCAL = {{ cookiecutter.gradle_path }}
MANIFEST        = app/src/main/AndroidManifest.xml
GRADLE          = ./gradlew

MAIN            = xmlstarlet select -T -t -v "//application/activity/@android:name" -n $(MANIFEST)
PACKAGE         = {{ cookiecutter.package_name }}

ADB_SELECTED_DEVICE := RX8N9045ELX
HOST                := celular
SEND_TEXT           ?=
PUBKEY              ?= id_rsa_celular.pub
SSH_HOST            ?= celular
SSH_PASS            ?= faa79e08
KNOWN_HOSTS         ?= $(HOME)/.ssh/known_hosts

log = @printf "\033[36m[make]\033[0m %s\n" $(1)

include mk/tools.mk
include mk/coordenade.mk

all: android

# ----------------------------------------------------------------------------
# ----------------------------- MAIN -----------------------------------------
# ----------------------------------------------------------------------------

build:
	$(call log,$@)
	$(GRADLE) assemble
init:
	$(call log,$@)
	$(MY_GRADLE_LOCAL) wrapper
run:
	$(call log,$@)
	$(AM) start -n $(PACKAGE)/`$(MAIN)`
install:
	$(call log,$@)
	$(GRADLE) $@Debug
uninstall:
	$(call log,$@)
	$(ADB_UNINSTALL) $(PACKAGE)
clean:
	$(call log,$@)
	$(GRADLE) $@

# ----------------------------------------------------------------------------
# ------------------------ ANDROID TOOLS -------------------------------------
# ----------------------------------------------------------------------------
include mk/energy.mk
include mk/packages.mk
include mk/scrcpy.mk
include mk/keycode.mk
include mk/onoff.mk

android: ## mostra informações gerais do dispositivo
	$(call log,$@)
	@echo "=== Android ==="
	@$(ADB) shell getprop ro.build.version.release

	@echo "=== Device ==="
	@$(ADB) shell getprop ro.product.model

	@echo "=== Serial ==="
	@$(ADB) get-serialno

	@echo "=== Battery ==="
	@$(ADB) shell dumpsys battery | grep -E 'level|status|temperature'

	@echo "=== Uptime ==="
	@$(ADB) shell uptime

	@echo "=== IP ==="
	@$(ADB) shell ip addr show wlan0 | grep 'inet '

	@echo "=== CPU ==="
	@$(ADB) shell cat /proc/cpuinfo | grep -E 'Hardware|processor' | tail -2
	@$(ADB) shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null | awk '{printf "Freq: %d MHz\n", $$1/1000}'

	@echo "=== RAM ==="
	@$(ADB) shell cat /proc/meminfo | grep -E 'MemTotal|MemFree|MemAvailable'

	@echo "=== Screen ==="
	@$(ADB) shell wm size
	@$(ADB) shell wm density

	@echo "=== Build ==="
	@$(ADB) shell getprop ro.build.id
	@$(ADB) shell getprop ro.product.brand
	@$(ADB) shell getprop ro.product.device

	@echo "=== Processes ==="
	@$(ADB) shell ps | wc -l

	@echo "=== Storage ==="
	@$(ADB) shell '\
		echo "Internal : $$(df -h /data | tail -1 | awk '\''{print $$2 " total, " $$3 " used, " $$4 " free"}'\'')"; \
		echo "Linux    : $$(df -h /data/local/mnt | tail -1 | awk '\''{print $$2 " total, " $$3 " used, " $$4 " free"}'\'')"; \
		echo "SD Card  : $$(df -h /storage/6166-6564 | tail -1 | awk '\''{print $$2 " total, " $$3 " used, " $$4 " free"}'\'')"; \
		echo "Emulated : $$(df -h /storage/emulated/0 | tail -1 | awk '\''{print $$2 " total, " $$3 " used, " $$4 " free"}'\'')"; \
	'

version:
	$(call log,$@)
	@$(ADB_EXEC_OUT) cat /proc/version

resolucao: ## mostra resolução da tela
	$(call log,$@)
	$(ADB_SHELL) wm size

devices: ## lista dispositivos conectados via ADB
	$(call log,$@)
	$(ADB) devices

shell: ## abre shell ADB
	$(call log,$@)
	$(ADB_SHELL)


# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
send-text: ## envia texto para o Android e aperta ENTER. Uso: make send-text SEND_TEXT="uma mensagem"
	$(call log,$@)
	@test -n "$(SEND_TEXT)" || { echo 'uso: make send-text SEND_TEXT="uma mensagem"'; exit 1; }
	@for word in $(SEND_TEXT); do \
		$(ADB) shell input text "$$word"; \
		$(ADB) shell input keyevent KEYCODE_SPACE; \
	done
	@$(ADB) shell input keyevent KEYCODE_BACKSPACE
	@$(ADB) shell input keyevent KEYCODE_ENTER

# -----------------------------------------------------------------------------
# TECLADO NUMÉRICO -- tela de bloqueio (PIN)
# -----------------------------------------------------------------------------

key-1: ## toca na tecla 1
	$(call log,$@)
	$(TAP) $(KEY_1_X) $(KEY_1_Y)

key-2: ## toca na tecla 2
	$(call log,$@)
	$(TAP) $(KEY_2_X) $(KEY_2_Y)

key-3: ## toca na tecla 3
	$(call log,$@)
	$(TAP) $(KEY_3_X) $(KEY_3_Y)

key-4: ## toca na tecla 4
	$(call log,$@)
	$(TAP) $(KEY_4_X) $(KEY_4_Y)

key-5: ## toca na tecla 5
	$(call log,$@)
	$(TAP) $(KEY_5_X) $(KEY_5_Y)

key-6: ## toca na tecla 6
	$(call log,$@)
	$(TAP) $(KEY_6_X) $(KEY_6_Y)

key-7: ## toca na tecla 7
	$(call log,$@)
	$(TAP) $(KEY_7_X) $(KEY_7_Y)

key-8: ## toca na tecla 8
	$(call log,$@)
	$(TAP) $(KEY_8_X) $(KEY_8_Y)

key-9: ## toca na tecla 9
	$(call log,$@)
	$(TAP) $(KEY_9_X) $(KEY_9_Y)

key-0: ## toca na tecla 0
	$(call log,$@)
	$(TAP) $(KEY_0_X) $(KEY_0_Y)

key-back: ## toca no backspace do teclado numérico
	$(call log,$@)
	$(TAP) $(KEY_back_X) $(KEY_back_Y)

key-next: ## toca em próximo/confirmar no teclado numérico
	$(call log,$@)
	$(TAP) $(KEY_next_X) $(KEY_next_Y)

# -----------------------------------------------------------------------------
# DOCK INFERIOR -- atalhos para os 5 slots
# -----------------------------------------------------------------------------

tap-app1: ## toca no app 1 do dock
	$(call log,$@)
	$(TAP) $(KEY_app1_X) $(KEY_app1_Y)

tap-app2: ## toca no app 2 do dock
	$(call log,$@)
	$(TAP) $(KEY_app2_X) $(KEY_app2_Y)

tap-app3: ## toca no app 3 do dock
	$(call log,$@)
	$(TAP) $(KEY_app3_X) $(KEY_app3_Y)

tap-app4: ## toca no app 4 do dock
	$(call log,$@)
	$(TAP) $(KEY_app4_X) $(KEY_app4_Y)

tap-app5: ## toca no app 5 do dock
	$(call log,$@)
	$(TAP) $(KEY_app5_X) $(KEY_app5_Y)

# -----------------------------------------------------------------------------
# DESBLOQUEIO -- PIN 2244 + swipes
# -----------------------------------------------------------------------------
KEY_2_BTN := $(KEY_2_X) $(KEY_2_Y)
KEY_4_BTN := $(KEY_4_X) $(KEY_4_Y)
unlock: ## digita o PIN 2244 e confirma
	$(call log,$@)
	$(TAP) $(KEY_2_BTN)
	$(TAP) $(KEY_2_BTN)
	$(TAP) $(KEY_4_BTN)
	$(TAP) $(KEY_4_BTN)
	$(KEYEVENT) KEYCODE_ENTER

swipe-up: ## desliza para cima na tela de bloqueio (desbloqueio)
	$(call log,$@)
	$(SWIPE) 540 1800 540 400 300

swipe-go-home: ## swipe de baixo para cima para ir à home
	$(call log,$@)
	$(SWIPE) 360 1382 360 200 300

open: ## liga tela, faz swipe e desbloqueia (sequência completa)
	$(call log,$@)
	$(MAKE) onoff-screen
	sleep 1
	$(MAKE) swipe-up
	sleep 1
	$(MAKE) unlock

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

# -----------------------------------------------------------------------------
# UI / DEBUG VISUAL -- uiautomator, bounds, coordenadas, screenshot
# -----------------------------------------------------------------------------

coords: ## ativa pointer_location e abre scrcpy para capturar coordenadas
	$(call log,$@)
	@$(SETTINGS) put system pointer_location 1
	@echo "Coordenadas ativas — pressione Ctrl+C para parar"
	@trap '$(SETTINGS) put system pointer_location 0' INT; \
	$(SCRCPY) --no-audio

coords-off: ## desativa pointer_location
	$(call log,$@)
	@$(SETTINGS) put system pointer_location 0

ui-dump: ## gera dump simples dos bounds da UI via uiautomator
	$(call log,$@)
	@$(UIAUTOMATOR) dump /sdcard/ui.xml
	@$(ADB_PULL) /sdcard/ui.xml /tmp/ui.xml >/dev/null
	@grep -o 'bounds="[^"]*"' /tmp/ui.xml | sort -u

ui-dump2: ## gera dump dos bounds da UI com centro calculado por awk
	$(call log,$@)
	@$(UIAUTOMATOR) dump /sdcard/ui.xml
	@$(ADB_PULL) /sdcard/ui.xml /tmp/ui.xml >/dev/null
	@grep -o 'bounds="[^"]*"' /tmp/ui.xml | sort -u | \
		awk -F'[][,]' '{ \
			x1=$$2; y1=$$3; x2=$$5; y2=$$6; \
			cx=int((x1+x2)/2); cy=int((y1+y2)/2); \
			printf "bounds=[%s,%s][%s,%s]  centro=(%s,%s)\n", x1,y1,x2,y2,cx,cy \
		}'

ui-info: ## mostra elementos da tela com texto, descrição e coordenadas (via ui-info.py)
	$(call log,$@)
	@$(UIAUTOMATOR) dump /sdcard/ui.xml
	@$(ADB_PULL) /sdcard/ui.xml /tmp/ui.xml >/dev/null 2>&1
	@python3 ui-info.py | tee ui.log

tap:
	$(call log,$@)
	@$(UIAUTOMATOR) dump /sdcard/ui.xml
	@$(ADB_PULL) /sdcard/ui.xml /tmp/ui.xml >/dev/null 2>&1
	@python3 ui-info.py > ui.log
	@./processa-taps.sh  < ui.log| ./tap-select.py

rolagem-down:
	@$(ADB_SHELL) input swipe 640 700 640 200
rolagem-up:
	@$(ADB_SHELL) input swipe 640 200 640 700

get-ui.log:
	$(call log,$@)
	@$(UIAUTOMATOR) dump /sdcard/ui.xml
	@$(ADB) pull /sdcard/ui.xml /tmp/ui.xml >/dev/null 2>&1
	@python3 ui-info.py > ui.log

select-exec-tap-linux-deploy: ui.log
	$(call log,$@)
	ADB_DEVICE=$(ADB_SELECTED_DEVICE) ./processa-taps.sh  < ui.log \
			   | grep -E 'Linux Deploy' \
			   | head -n 1 \
			   | tr -s ' ' \
			   |cut -d: -f2- \
			   | sh

# volume-up:
# 	@$(KEYEVENT) KEYCODE_VOLUME_UP
# volume-down:
# 	@$(KEYEVENT) KEYCODE_VOLUME_DOWN

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

text:
	$(TEXT) "ps -a"

# =============================================================================
# Navegação principal
# =============================================================================
back: ## envia botão voltar
	$(KEYEVENT) KEYCODE_BACK
home: ## envia botão home
	$(KEYEVENT) KEYCODE_HOME
menu: ## envia botão menu
	$(KEYEVENT) KEYCODE_MENU
ok: ## envia botão OK (dpad center)
	$(KEYEVENT) KEYCODE_DPAD_CENTER
recents: ## abre apps recentes
	$(KEYEVENT) KEYCODE_APP_SWITCH
search: ## abre busca
	$(KEYEVENT) KEYCODE_SEARCH
assist: ## abre assistente (API 19)
	$(KEYEVENT) KEYCODE_ASSIST
voice-assist: ## assistente de voz (API 21)
	$(KEYEVENT) KEYCODE_VOICE_ASSIST
all-apps: ## todos os apps (API 28)
	$(KEYEVENT) KEYCODE_ALL_APPS
refresh: ## atualiza (API 28)
	$(KEYEVENT) KEYCODE_REFRESH
# help: ## abre ajuda (API 23)
# 	$(KEYEVENT) KEYCODE_HELP
settings: ## abre configurações
	$(KEYEVENT) KEYCODE_SETTINGS
notification: ## abre notificações
	$(KEYEVENT) KEYCODE_NOTIFICATION
profile-switch: ## troca perfil (API 29)
	$(KEYEVENT) KEYCODE_PROFILE_SWITCH

# -----------------------------------------------------------------------------
# HELP
# -----------------------------------------------------------------------------

help: ## mostra este help
	$(call log,$@)
	@echo ""
	@echo "Samsung Galaxy A21s -- ADB / Linux Deploy helpers"
	@echo ""
	@echo "Uso:"
	@echo "  make <target>"
	@echo ""
	@echo "Exemplos:"
	@echo "  make devices"
	@echo "  make open"
	@echo "  make ui-info"
	@echo "  make deploy"
	@echo "  make scrcpy"
	@echo ""
	@echo "Targets disponíveis:"
	@grep -h -E '^[a-zA-Z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-26s\033[0m %s\n", $$1, $$2}' || true
	@echo ""
