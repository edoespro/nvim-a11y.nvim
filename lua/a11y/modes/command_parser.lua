-- lua/a11y/modes/command_parser.lua
-- Máquina de estados que interpreta secuencias de teclas
-- siguiendo la gramática de Neovim:
-- [count] + operador + [count] + movimiento/objeto
-- Reutilizable por cualquier modo que necesite interpretar secuencias.

local M = {}

-- ─────────────────────────────────────────
-- Estados de la máquina
-- ─────────────────────────────────────────

local STATES = {
  IDLE             = "idle",
  COUNT            = "count",
  OPERATOR_PENDING = "operator_pending",
  COUNT2           = "count2",
}

-- ─────────────────────────────────────────
-- Clasificación de teclas
-- ─────────────────────────────────────────

local operators = {
  d = "delete",
  c = "change",
  y = "yank",
  g = "g_prefix",
  ["~"] = "swap_case",
  [">"] = "indent_right",
  ["<"] = "indent_left",
  ["="] = "reindent",
}

local motions = {
  h = "char_left",
  l = "char_right",
  j = "line_down",
  k = "line_up",
  w = "word_forward",
  b = "word_backward",
  e = "word_end",
  W = "WORD_forward",
  B = "WORD_backward",
  E = "WORD_end",
  ["0"] = "line_start",
  ["^"] = "line_first_char",
  ["$"] = "line_end",
  G = "file_end",
  ["gg"] = "file_start",
  ["{"] = "paragraph_up",
  ["}"] = "paragraph_down",
  ["%"] = "match_pair",
  f = "find_char_forward",
  F = "find_char_backward",
  t = "till_char_forward",
  T = "till_char_backward",
}

local immediate_actions = {
  i = "insert",
  a = "append",
  o = "open_below",
  O = "open_above",
  x = "delete_char",
  p = "paste_after",
  P = "paste_before",
  u = "undo",
  v = "visual",
  V = "visual_line",
  ["."] = "repeat_last",
  ["dd"] = "delete_line",
  ["yy"] = "yank_line",
  ["cc"] = "change_line",
  ["D"]  = "delete_to_end",
  ["C"]  = "change_to_end",
  ["Y"]  = "yank_to_end",
}

-- ─────────────────────────────────────────
-- Constructor
-- ─────────────────────────────────────────

-- Crea una nueva instancia del parser.
-- on_action: callback llamado cuando se completa una secuencia válida
--   recibe: { count, operator, count2, motion, action }
-- on_pending: callback llamado cuando hay una secuencia incompleta
--   recibe: { state, buffer }
-- on_cancel: callback llamado cuando se cancela con Escape
function M.new(on_action, on_pending, on_cancel)
  local parser = {
    state    = STATES.IDLE,
    count    = 0,
    count2   = 0,
    operator = nil,
    buffer   = "",  -- acumula teclas para secuencias como "gg", "dd"
  }

  -- ─────────────────────────────────────────
  -- Procesamiento de teclas
  -- ─────────────────────────────────────────

  function parser:feed(key)
    -- Escape cancela siempre
    if key == "<Esc>" then
      self:_reset()
      if on_cancel then on_cancel() end
      return
    end

    if self.state == STATES.IDLE then
      self:_handle_idle(key)

    elseif self.state == STATES.COUNT then
      self:_handle_count(key)

    elseif self.state == STATES.OPERATOR_PENDING then
      self:_handle_operator_pending(key)

    elseif self.state == STATES.COUNT2 then
      self:_handle_count2(key)
    end
  end

  -- ─────────────────────────────────────────
  -- Manejadores por estado
  -- ─────────────────────────────────────────

  function parser:_handle_idle(key)
    -- Número: inicia conteo (excepto 0 que es movimiento)
    if key:match("^[1-9]$") then
      self.count = tonumber(key)
      self.state = STATES.COUNT
      self.buffer = key
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- 0 en idle es movimiento inicio de línea
    if key == "0" then
      if on_action then on_action({
        count    = 1,
        operator = nil,
        count2   = 1,
        motion   = "line_start",
        action   = nil,
      }) end
      return
    end

    -- Acumular buffer para secuencias dobles (gg, dd, yy, cc)
    self.buffer = self.buffer .. key
    local buffered = self.buffer

    -- Verificar acción inmediata con buffer acumulado
    if immediate_actions[buffered] then
      if on_action then on_action({
        count    = 1,
        operator = nil,
        count2   = 1,
        motion   = nil,
        action   = immediate_actions[buffered],
      }) end
      self:_reset()
      return
    end

    -- Verificar operador
    if operators[key] then
      self.operator = operators[key]
      self.state    = STATES.OPERATOR_PENDING
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- Verificar movimiento directo
    if motions[key] then
      if on_action then on_action({
        count    = 1,
        operator = nil,
        count2   = 1,
        motion   = motions[key],
        action   = nil,
      }) end
      self:_reset()
      return
    end

    -- Verificar acción inmediata simple
    if immediate_actions[key] then
      if on_action then on_action({
        count    = 1,
        operator = nil,
        count2   = 1,
        motion   = nil,
        action   = immediate_actions[key],
      }) end
      self:_reset()
      return
    end

    -- Tecla no reconocida: resetear
    self:_reset()
  end

  function parser:_handle_count(key)
    -- Más números: acumular conteo
    if key:match("^[0-9]$") then
      self.count  = self.count * 10 + tonumber(key)
      self.buffer = self.buffer .. key
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- Operador después del count
    if operators[key] then
      self.operator = operators[key]
      self.state    = STATES.OPERATOR_PENDING
      self.buffer   = self.buffer .. key
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- Movimiento directo después del count
    if motions[key] then
      if on_action then on_action({
        count    = self.count,
        operator = nil,
        count2   = 1,
        motion   = motions[key],
        action   = nil,
      }) end
      self:_reset()
      return
    end

    self:_reset()
  end

  function parser:_handle_operator_pending(key)
    -- Número: inicia count2
    if key:match("^[1-9]$") then
      self.count2 = tonumber(key)
      self.state  = STATES.COUNT2
      self.buffer = self.buffer .. key
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- Movimiento: completar secuencia
    if motions[key] then
      if on_action then on_action({
        count    = self.count > 0 and self.count or 1,
        operator = self.operator,
        count2   = 1,
        motion   = motions[key],
        action   = nil,
      }) end
      self:_reset()
      return
    end

    -- Operador repetido (dd, yy, cc)
    local repeated = self.buffer .. key
    if immediate_actions[repeated] then
      if on_action then on_action({
        count    = self.count > 0 and self.count or 1,
        operator = nil,
        count2   = 1,
        motion   = nil,
        action   = immediate_actions[repeated],
      }) end
      self:_reset()
      return
    end

    self:_reset()
  end

  function parser:_handle_count2(key)
    -- Más números: acumular count2
    if key:match("^[0-9]$") then
      self.count2 = self.count2 * 10 + tonumber(key)
      self.buffer = self.buffer .. key
      if on_pending then on_pending({ state = self.state, buffer = self.buffer }) end
      return
    end

    -- Movimiento: completar secuencia compleja
    if motions[key] then
      if on_action then on_action({
        count    = self.count > 0 and self.count or 1,
        operator = self.operator,
        count2   = self.count2,
        motion   = motions[key],
        action   = nil,
      }) end
      self:_reset()
      return
    end

    self:_reset()
  end

  -- ─────────────────────────────────────────
  -- Utilería interna
  -- ─────────────────────────────────────────

  function parser:_reset()
    self.state    = STATES.IDLE
    self.count    = 0
    self.count2   = 0
    self.operator = nil
    self.buffer   = ""
  end

  function parser:current_state()
    return {
      state    = self.state,
      count    = self.count,
      count2   = self.count2,
      operator = self.operator,
      buffer   = self.buffer,
    }
  end

  return parser
end

return M
