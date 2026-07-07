#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# 人生中点 (LifeMidpoint) — 一键启动脚本
#
#   ./run.sh            在 iOS 模拟器里跑起来 (第一次运行会自动装好所有依赖)
#   ./run.sh device     装到真机上调试 (需要先完成一次性配对, 见 README.md)
#
# 两种模式都会自动: 装依赖 -> xcodegen 生成项目 -> 启动本地 AI 后端 -> 编译 -> 安装 -> 启动。
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

MODE="${1:-simulator}"
case "$MODE" in
  -h|--help)
    sed -n '3,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  simulator|device) ;;
  *)
    echo "未知参数: $MODE (只支持 simulator / device, 留空默认 simulator)"
    exit 1
    ;;
esac

SCHEME="LifeMidpoint"
BUNDLE_ID="com.lifemidpoint.app"
AGENT_PORT="${AGENT_PORT:-8787}"

# 构建产物故意放在 ~/Library 下, 不放进项目目录本身:
# 如果项目被克隆/存放在 ~/Desktop、~/iCloud Drive 之类被"iCloud Drive 桌面与
# 文稿"同步的目录里, 编译过程中新建出来的 .app 目录会被 iCloud 的文件供应方进程
# 打上 com.apple.FinderInfo / com.apple.fileprovider.* 扩展属性, 导致最后一步
# CodeSign 报错 "resource fork, Finder information, or similar detritus not
# allowed" 而整体构建失败。~/Library 不受该同步功能影响, 从根源避免这个坑,
# 不管项目本身放在电脑哪个目录都不受影响。
DERIVED_DATA_BASE="$HOME/Library/Developer/Xcode/LifeMidpointRunData"

log()  { echo "==> $*"; }
warn() { echo "⚠️  $*" >&2; }
die()  { echo "❌ $*" >&2; exit 1; }

# ----------------------------------------------------------------------------
# Step 1. 依赖自举 (幂等: 已安装的都会跳过)
# ----------------------------------------------------------------------------

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then return; fi
  log "未检测到 Homebrew, 正在安装 (需要网络, 可能会要求输入一次开机密码)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
}

ensure_brew_package() {
  local formula="$1" bin="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then return; fi
  ensure_homebrew
  log "安装 $formula ..."
  brew install "$formula"
}

ensure_bun() {
  export PATH="$HOME/.bun/bin:$PATH"
  if command -v bun >/dev/null 2>&1; then return; fi
  log "未检测到 Bun (agent-server 运行时), 正在安装..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
  command -v bun >/dev/null 2>&1 || die "Bun 安装失败, 请手动执行: curl -fsSL https://bun.sh/install | bash"
}

ensure_xcode() {
  local dev_dir
  dev_dir="$(xcode-select -p 2>/dev/null || true)"
  if [[ -z "$dev_dir" || "$dev_dir" != *"Xcode.app"* ]]; then
    die "需要完整版 Xcode (不是只有 Command Line Tools)。请先从 App Store 安装 Xcode, 打开一次并同意许可协议, 然后执行:
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  fi
  command -v xcodebuild >/dev/null 2>&1 || die "xcodebuild 不可用, 请确认 Xcode 已正确安装。"
}

ensure_dependencies() {
  log "检查依赖 (Homebrew / XcodeGen / Bun / Xcode) ..."
  ensure_xcode
  ensure_brew_package xcodegen
  ensure_bun
  if [[ "$MODE" == "device" ]]; then
    ensure_brew_package qrencode
  fi
}

ensure_agent_env() {
  if [[ -f "$PROJECT_ROOT/agent-server/.env" ]]; then return; fi
  warn "未找到 agent-server/.env (本地 AI 后端的模型 key 配置)。"
  cp "$PROJECT_ROOT/agent-server/.env.example" "$PROJECT_ROOT/agent-server/.env"
  die "已从 .env.example 生成 agent-server/.env, 请打开它填入 LLM_API_KEY 后重新运行 ./run.sh
    (默认对接智谱 GLM, 在 https://open.bigmodel.cn/ 免费申请一个 key 即可; 也可以改成任意 OpenAI 兼容接口, 改 .env 里的 LLM_BASE_URL/LLM_MODEL 不用改代码)"
}

# ----------------------------------------------------------------------------
# Step 2. 生成 Xcode 项目
# ----------------------------------------------------------------------------

generate_project() {
  log "xcodegen generate ..."
  xcodegen generate
}

# ----------------------------------------------------------------------------
# Step 3a. 模拟器流程
# ----------------------------------------------------------------------------

run_simulator() {
  local sim_name="${SIMULATOR_NAME:-iPhone 17 Pro}"
  local derived_data="$DERIVED_DATA_BASE/simulator"
  local app_path="$derived_data/Build/Products/Debug-iphonesimulator/LifeMidpoint.app"

  log "启动本地 AI 后端 (127.0.0.1:$AGENT_PORT) ..."
  AGENT_PORT="$AGENT_PORT" bash "$PROJECT_ROOT/scripts/start_agent_server.sh"

  log "编译 $SCHEME (Debug / 模拟器) ..."
  xcodebuild \
    -project LifeMidpoint.xcodeproj \
    -scheme "$SCHEME" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$sim_name" \
    -derivedDataPath "$derived_data" \
    build

  [[ -d "$app_path" ]] || die "未找到构建产物: $app_path"

  log "查找模拟器: $sim_name"
  local udid
  udid="$(xcrun simctl list devices available | awk -v name="$sim_name" '
    $0 ~ name && match($0, /\([A-F0-9-]+\)/) {
      print substr($0, RSTART + 1, RLENGTH - 2); exit
    }')"
  [[ -n "$udid" ]] || die "找不到模拟器 \"$sim_name\", 请在 Xcode > Settings > Components 里下载对应 iOS Simulator。"

  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  open -a Simulator
  log "安装 + 启动 App ..."
  xcrun simctl install "$udid" "$app_path"
  xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE_ID"

  cat <<EOF

✅ 完成!
   AI 后端: http://127.0.0.1:$AGENT_PORT/health
   App    : 已在模拟器 "$sim_name" 上启动 ($BUNDLE_ID)
EOF
}

# ----------------------------------------------------------------------------
# Step 3b. 真机流程 (无需 Apple 开发者账号, 但需要一次性配对, 见 README「真机调试」)
# ----------------------------------------------------------------------------

# 从 devicectl 的 JSON 里挑一台已配对的 iOS 设备, 把关键字段回填到几个全局变量里:
#   DEVICE_ID           devicectl 自己的 identifier, 给 `devicectl device install/launch --device` 用
#   DEVICE_UDID          硬件 UDID, 给 `xcodebuild -destination platform=iOS,id=...` 用
#                         (这两个字段格式不同、不能混用, devicectl 命令和 xcodebuild 命令各认各的)
#   DEVICE_NAME          设备名, 仅用于日志展示
#   DEVICE_TUNNEL_STATE  是否已建立开发隧道 (connected 才说明真的能直接编译安装)
# 优先选 tunnelState=connected 的设备(当前正连着的); 多台已配对设备时避免选到一台早已不在身边的旧设备。
# 找不到则把 DEVICE_ID 留空, 由调用方决定如何提示用户。
pick_device() {
  local json="$PROJECT_ROOT/tmp/devicectl-list.json"
  mkdir -p "$PROJECT_ROOT/tmp"
  xcrun devicectl list devices --json-output "$json" >/dev/null 2>&1 || true

  local picked
  picked="$(python3 - "$json" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except Exception:
    print("||||")
    sys.exit()
devices = data.get("result", {}).get("devices", [])
paired = [d for d in devices if d.get("connectionProperties", {}).get("pairingState") == "paired"
          and d.get("hardwareProperties", {}).get("platform") == "iOS"]
if not paired:
    print("||||")
    sys.exit()
# 优先选当前隧道已连接的设备, 其次退而求其次选第一个已配对的。
paired.sort(key=lambda d: d.get("connectionProperties", {}).get("tunnelState") != "connected")
d = paired[0]
fields = [
    d.get("identifier", ""),
    d.get("hardwareProperties", {}).get("udid", ""),
    d.get("deviceProperties", {}).get("name", "iPhone"),
    d.get("connectionProperties", {}).get("tunnelState", "unknown"),
]
print("|".join(fields))
PY
)"
  DEVICE_ID="$(echo "$picked" | cut -d'|' -f1)"
  DEVICE_UDID="$(echo "$picked" | cut -d'|' -f2)"
  DEVICE_NAME="$(echo "$picked" | cut -d'|' -f3)"
  DEVICE_TUNNEL_STATE="$(echo "$picked" | cut -d'|' -f4)"
}

run_device() {
  log "查找已配对的 iPhone (xcrun devicectl) ..."
  pick_device

  if [[ -z "${DEVICE_ID:-}" ]]; then
    die "没有找到已配对的 iOS 设备。首次使用真机调试需要做一次性配对 (只需一次, 之后都能无线复用):
    1. 用数据线把 iPhone 接到这台 Mac 上, 在手机上点「信任此电脑」
    2. 打开一次 Xcode, 在 Settings > Accounts 里登录你的 Apple ID (免费账号即可)
    3. Xcode 顶部设备下拉栏选中这台 iPhone 一次, 等它显示 \"就绪\"
    4. iPhone 上: 设置 > 隐私与安全性 > 开发者模式, 打开并重启手机
    详细步骤见 README.md「真机调试」章节。做完这些之后重新运行 ./run.sh device 即可。"
  fi

  log "找到设备: $DEVICE_NAME ($DEVICE_ID), 当前状态: $DEVICE_TUNNEL_STATE"
  if [[ "$DEVICE_TUNNEL_STATE" != "connected" ]]; then
    warn "设备当前不是「connected」状态 (是: $DEVICE_TUNNEL_STATE)。"
    warn "请确认 iPhone 和这台 Mac 连在同一个 Wi-Fi (或用数据线接一次), 屏幕已解锁。"
    warn "仍会继续尝试, 如果下面构建/安装失败, 大概率就是这个原因。"
  fi

  local mac_host derived_data app_path health_url
  mac_host="$(scutil --get LocalHostName 2>/dev/null || hostname -s).local"
  derived_data="$DERIVED_DATA_BASE/device"
  app_path="$derived_data/Build/Products/Debug-iphoneos/LifeMidpoint.app"
  health_url="http://${mac_host}:${AGENT_PORT}/health"

  log "启动本地 AI 后端 (对局域网开放: 0.0.0.0:$AGENT_PORT, 手机通过 $mac_host 访问) ..."
  AGENT_PORT="$AGENT_PORT" AGENT_HOST=0.0.0.0 bash "$PROJECT_ROOT/scripts/start_agent_server.sh"

  log "编译 $SCHEME (Debug / 真机) ..."
  log "  (第一次给这台设备签名可能会跳出 Apple ID 相关提示, 按提示操作一次即可)"
  local team_args=()
  if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
    team_args=(DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM")
  fi
  xcodebuild \
    -project LifeMidpoint.xcodeproj \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "platform=iOS,id=$DEVICE_UDID" \
    -derivedDataPath "$derived_data" \
    -allowProvisioningUpdates \
    "AGENT_SERVER_BASE_URL=http://${mac_host}:${AGENT_PORT}" \
    "${team_args[@]+"${team_args[@]}"}" \
    build

  [[ -d "$app_path" ]] || die "未找到构建产物: $app_path"

  log "安装到设备 ..."
  xcrun devicectl device install app --device "$DEVICE_ID" "$app_path"

  log "启动 App ..."
  xcrun devicectl device process launch --terminate-existing --device "$DEVICE_ID" "$BUNDLE_ID"

  generate_qr "$health_url"

  cat <<EOF

✅ 完成!
   AI 后端  : $health_url  (手机和 Mac 需在同一 Wi-Fi 下才能访问)
   App     : 已装到 "$DEVICE_NAME" 并启动 ($BUNDLE_ID)
   查看后端日志: tail -f "$PROJECT_ROOT/tmp/agent-server/agent-server.log"
   查看 App 实时日志: xcrun devicectl device process launch --console --device $DEVICE_ID $BUNDLE_ID
EOF
}

# 生成一个二维码, 扫码可以在手机 Safari 里直接打开本地 AI 后端的健康检查页面,
# 用来快速确认"手机确实能连到 Mac 的局域网服务"——这是真机调试最常见的失败点。
generate_qr() {
  local url="$1"
  local out_png="$PROJECT_ROOT/tmp/agent-server/health-check-qrcode.png"
  if ! command -v qrencode >/dev/null 2>&1; then
    warn "未安装 qrencode, 跳过二维码生成 (可执行 brew install qrencode 后重跑)。"
    return
  fi
  qrencode -o "$out_png" "$url"
  echo ""
  echo "📱 用 iPhone 摄像头扫这个二维码, 可以在 Safari 里验证手机能不能连到 Mac 的本地服务:"
  qrencode -t ANSIUTF8 "$url"
  echo "   (二维码图片也存了一份: $out_png)"
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

ensure_dependencies
ensure_agent_env
generate_project

if [[ "$MODE" == "device" ]]; then
  run_device
else
  run_simulator
fi
