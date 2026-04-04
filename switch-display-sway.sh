#!/usr/bin/env bash
# toggle-display.sh — управление мониторами в Sway (Manjaro)
# Отключает встроенный экран ноутбука и переключает на внешний монитор

# ──────────────────────────────────────────────
# Определяем имена выходов (outputs)
# Запусти `swaymsg -t get_outputs` чтобы узнать свои имена
# ──────────────────────────────────────────────
INTERNAL="eDP-1"          # Встроенный экран ноутбука (обычно eDP-1 или eDP-2)
EXTERNAL="HDMI-A-1"       # Внешний монитор (HDMI-A-1, DP-1, DP-2 и т.д.)

# Разрешение и позиция внешнего монитора (измени под свой монитор)
EXT_RESOLUTION="1920x1080"
EXT_REFRESH="60"
EXT_POSITION="0 0"

# ──────────────────────────────────────────────
# Проверка зависимостей
# ──────────────────────────────────────────────
if ! command -v swaymsg &>/dev/null; then
    echo "Ошибка: swaymsg не найден. Скрипт работает только в Sway." >&2
    exit 1
fi

# ──────────────────────────────────────────────
# Получаем текущее состояние мониторов
# ──────────────────────────────────────────────
get_output_status() {
    local output="$1"
    swaymsg -t get_outputs 2>/dev/null \
        | grep -A5 "\"name\": \"$output\"" \
        | grep '"active"' \
        | grep -o 'true\|false'
}

INTERNAL_STATUS=$(get_output_status "$INTERNAL")
EXTERNAL_STATUS=$(get_output_status "$EXTERNAL")

# ──────────────────────────────────────────────
# Проверяем, подключён ли внешний монитор
# ──────────────────────────────────────────────
EXTERNAL_CONNECTED=$(swaymsg -t get_outputs 2>/dev/null | grep "\"name\": \"$EXTERNAL\"")

if [[ -z "$EXTERNAL_CONNECTED" ]]; then
    echo "Внешний монитор ($EXTERNAL) не обнаружен."
    echo "Доступные выходы:"
    swaymsg -t get_outputs | grep '"name"'
    exit 1
fi

# ──────────────────────────────────────────────
# Логика переключения
# ──────────────────────────────────────────────
MODE="${1:-auto}"  # Режим: auto | external | internal | mirror

case "$MODE" in

    external | ext)
        echo "→ Только внешний монитор ($EXTERNAL)"
        swaymsg "output $EXTERNAL enable resolution ${EXT_RESOLUTION}@${EXT_REFRESH}Hz position $EXT_POSITION"
        swaymsg "output $INTERNAL disable"
        ;;

    internal | int)
        echo "→ Только встроенный монитор ($INTERNAL)"
        swaymsg "output $INTERNAL enable"
        swaymsg "output $EXTERNAL disable"
        ;;

    mirror)
        echo "→ Режим зеркала ($INTERNAL + $EXTERNAL)"
        swaymsg "output $INTERNAL enable"
        swaymsg "output $EXTERNAL enable resolution ${EXT_RESOLUTION}@${EXT_REFRESH}Hz position $EXT_POSITION"
        ;;

    extend)
        echo "→ Расширенный рабочий стол"
        INT_WIDTH=$(swaymsg -t get_outputs | grep -A20 "\"name\": \"$INTERNAL\"" \
            | grep '"width"' | head -1 | grep -o '[0-9]*')
        INT_WIDTH="${INT_WIDTH:-1920}"
        swaymsg "output $INTERNAL enable position 0 0"
        swaymsg "output $EXTERNAL enable resolution ${EXT_RESOLUTION}@${EXT_REFRESH}Hz position ${INT_WIDTH} 0"
        ;;

    auto | *)
        # Автоматическое переключение: если внешний активен — отключить,
        # если отключён — включить и выключить внутренний
        if [[ "$EXTERNAL_STATUS" == "true" ]]; then
            echo "→ Внешний монитор активен. Переключаемся на встроенный..."
            swaymsg "output $INTERNAL enable"
            swaymsg "output $EXTERNAL disable"
        else
            echo "→ Переключаемся на внешний монитор..."
            swaymsg "output $EXTERNAL enable resolution ${EXT_RESOLUTION}@${EXT_REFRESH}Hz position $EXT_POSITION"
            swaymsg "output $INTERNAL disable"
        fi
        ;;
esac

# ──────────────────────────────────────────────
# Информация о текущем состоянии после переключения
# ──────────────────────────────────────────────
echo ""
echo "Текущие выходы:"
swaymsg -t get_outputs | grep -E '"name"|"active"|"resolution"' | \
    sed 's/^[[:space:]]*/  /'

exit 0
