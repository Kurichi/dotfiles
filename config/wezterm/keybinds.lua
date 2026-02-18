local wezterm = require("wezterm")
local act = wezterm.action

-- コピーモード終了アクション
local close_copy_mode = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } })

-- ペインを均等化する
local function equalize_panes(window, tab)
  local panes = tab:panes()
  local num_panes = #panes
  if num_panes <= 1 then
    return
  end

  -- ペインを左から右の順にソート
  table.sort(panes, function(a, b)
    return a:get_dimensions().pixel_left < b:get_dimensions().pixel_left
  end)

  local tab_cols = tab:get_size().cols
  local target_cols = math.floor(tab_cols / num_panes)

  -- 複数回イテレーションして収束させる
  for _ = 1, 3 do
    for i = 1, num_panes - 1 do
      local p = panes[i]
      local cols = p:get_dimensions().cols
      local diff = target_cols - cols

      if math.abs(diff) > 1 then
        p:activate()
        local dir = diff > 0 and "Right" or "Left"
        window:perform_action(act.AdjustPaneSize({ dir, math.abs(diff) }), p)
      end
    end
  end
end

-- 均等分割: 分割後にペインを均等化する
local function smart_split(direction)
  return wezterm.action_callback(function(window, pane)
    local tab = pane:tab()

    -- 分割
    pane:split({ direction = direction })

    -- 均等化
    equalize_panes(window, tab)

    -- 新しいペイン（右端）をアクティブに
    local panes = tab:panes()
    panes[#panes]:activate()
  end)
end

-- 通知ステート（ウィンドウごとにコピー通知の有効期限を管理）
local copy_notification_until = {} -- window_id -> expire timestamp

-- ステータスバーにアクティブなキーテーブルまたは通知を表示
wezterm.on("update-right-status", function(window, _)
  local wid = tostring(window:window_id())
  if copy_notification_until[wid] and os.time() < copy_notification_until[wid] then
    window:set_right_status("📋 Copied!")
    return
  end
  copy_notification_until[wid] = nil
  local name = window:active_key_table()
  window:set_right_status(name and ("TABLE: " .. name) or "")
end)

-- タブ番号キーバインディングを生成 (Cmd+1〜8)
local function generate_tab_keys()
  local keys = {}
  for i = 1, 8 do
    table.insert(keys, { key = tostring(i), mods = "SUPER", action = act.ActivateTab(i - 1) })
  end
  return keys
end

-- メインキーバインディング
local keys = {
  -- ペイン
  { key = "d", mods = "SUPER", action = smart_split("Right") },
  { key = "[", mods = "SUPER", action = act.ActivatePaneDirection("Left") },
  { key = "]", mods = "SUPER", action = act.ActivatePaneDirection("Right") },
  { key = "j", mods = "SUPER", action = act.ActivatePaneDirection("Left") },
  { key = "k", mods = "SUPER", action = act.ActivatePaneDirection("Right") },
  { key = "w", mods = "SUPER", action = act.CloseCurrentPane({ confirm = true }) },

  -- タブ
  { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "h", mods = "SUPER", action = act.ActivateTabRelative(-1) },
  { key = "l", mods = "SUPER", action = act.ActivateTabRelative(1) },

  -- クリップボード・検索
  { key = "c", mods = "SUPER",      action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER",      action = act.PasteFrom("Clipboard") },
  { key = "f", mods = "SUPER",      action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "x", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },

  -- アプリ
  { key = "q", mods = "SUPER", action = act.QuitApplication },
  { key = "n", mods = "SUPER", action = act.SpawnWindow },
  { key = "r", mods = "SUPER", action = act.ReloadConfiguration },

  -- フォント
  { key = "+", mods = "SUPER", action = act.IncreaseFontSize },
  { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
  { key = "0", mods = "SUPER", action = act.ResetFontSize },

  -- その他
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },

  -- 直前のコマンドと出力をコピー (Semantic Zones 利用)
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.ActivateCopyMode, pane)
      window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)
      window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
      window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)
      window:perform_action(act.CopyMode("MoveUp"), pane)
      window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)
      window:perform_action(
        act.Multiple({
          { CopyTo = "ClipboardAndPrimarySelection" },
          close_copy_mode,
        }),
        pane
      )
      copy_notification_until[tostring(window:window_id())] = os.time() + 3
    end),
  },
}

-- タブ番号キーを追加
for _, k in ipairs(generate_tab_keys()) do
  table.insert(keys, k)
end

-- コピーモード (Vim風)
local copy_mode = {
  -- 終了
  { key = "Escape", mods = "NONE", action = close_copy_mode },
  { key = "q",      mods = "NONE", action = close_copy_mode },
  { key = "c",      mods = "CTRL", action = close_copy_mode },
  { key = "g",      mods = "CTRL", action = close_copy_mode },

  -- 移動 (基本)
  { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
  { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
  { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
  { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

  -- 移動 (単語)
  { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
  { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
  { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },

  -- 移動 (行)
  { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
  { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
  { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },

  -- 移動 (ページ/バッファ)
  { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
  { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
  { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
  { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
  { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
  { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
  { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
  { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
  { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },

  -- ジャンプ (f/t)
  { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
  { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
  { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
  { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
  { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
  { key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },

  -- 選択
  { key = "v",     mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
  { key = "V",     mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
  { key = "v",     mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
  { key = "o",     mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
  { key = "O",     mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
  { key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },

  -- ヤンク
  {
    key = "y",
    mods = "NONE",
    action = act.Multiple({
      { CopyTo = "ClipboardAndPrimarySelection" },
      close_copy_mode,
    }),
  },

  -- 矢印キー・その他
  { key = "Tab",        mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
  { key = "Tab",        mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
  { key = "Enter",      mods = "NONE",  action = act.CopyMode("MoveToStartOfNextLine") },
  { key = "PageUp",     mods = "NONE",  action = act.CopyMode("PageUp") },
  { key = "PageDown",   mods = "NONE",  action = act.CopyMode("PageDown") },
  { key = "Home",       mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
  { key = "End",        mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
  { key = "LeftArrow",  mods = "NONE",  action = act.CopyMode("MoveLeft") },
  { key = "LeftArrow",  mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
  { key = "RightArrow", mods = "NONE",  action = act.CopyMode("MoveRight") },
  { key = "RightArrow", mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
  { key = "UpArrow",    mods = "NONE",  action = act.CopyMode("MoveUp") },
  { key = "DownArrow",  mods = "NONE",  action = act.CopyMode("MoveDown") },
  { key = "b",          mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
  { key = "f",          mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
  { key = "m",          mods = "ALT",   action = act.CopyMode("MoveToStartOfLineContent") },
}

-- 検索モード
local search_mode = {
  { key = "Enter",     mods = "NONE", action = act.CopyMode("PriorMatch") },
  { key = "Escape",    mods = "NONE", action = act.CopyMode("Close") },
  { key = "n",         mods = "CTRL", action = act.CopyMode("NextMatch") },
  { key = "p",         mods = "CTRL", action = act.CopyMode("PriorMatch") },
  { key = "r",         mods = "CTRL", action = act.CopyMode("CycleMatchType") },
  { key = "u",         mods = "CTRL", action = act.CopyMode("ClearPattern") },
  { key = "PageUp",    mods = "NONE", action = act.CopyMode("PriorMatchPage") },
  { key = "PageDown",  mods = "NONE", action = act.CopyMode("NextMatchPage") },
  { key = "UpArrow",   mods = "NONE", action = act.CopyMode("PriorMatch") },
  { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
}

return {
  keys = keys,
  key_tables = {
    copy_mode = copy_mode,
    search_mode = search_mode,
  },
}
