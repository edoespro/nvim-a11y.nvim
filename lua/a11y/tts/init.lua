-- lua/a11y/tts/init.lua
-- Interfaz pública de la utilería TTS
-- Cualquier módulo puede requerir este archivo y usar sus funciones
-- Los eventos que expone son solo para monitoreo

local queue = require("a11y.tts.queue")

local M = {}

-- ─────────────────────────────────────────
-- Listeners internos para eventos de monitoreo
-- Estructura: { evento = { handler1, handler2, ... } }
-- ─────────────────────────────────────────

local listeners = {}

-- Registra un handler para un evento de monitoreo
-- Eventos disponibles: "start", "finish", "cancel", "error"
function M.on(event, handler)
  if not listeners[event] then
    listeners[event] = {}
  end
  table.insert(listeners[event], handler)
end

-- Despacha un evento de monitoreo a todos sus handlers
local function dispatch(event, data)
  if not listeners[event] then return end
  for _, handler in ipairs(listeners[event]) do
    handler(data)
  end
end

-- ─────────────────────────────────────────
-- Interfaz pública
-- ─────────────────────────────────────────

-- Encola un mensaje respetando prioridad y turno
-- opts = { priority, insert_type }
function M.speak(text, opts)
  opts = opts or {}
  dispatch("start", { text = text })

  queue.add({
    text        = text,
    priority    = opts.priority    or 3,
    insert_type = opts.insert_type or "queue",
  })
end

-- Interrumpe el mensaje actual y habla inmediatamente
function M.interrupt(text)
  dispatch("cancel", {})
  M.speak(text, { priority = 1, insert_type = "interrupt" })
end

-- Vacía la cola y habla inmediatamente
function M.flush(text)
  dispatch("cancel", {})
  M.speak(text, { priority = 2, insert_type = "flush" })
end

-- Detiene toda la voz y vacía la cola
function M.stop()
  queue.clear()
  dispatch("cancel", {})
end

-- Estado actual
function M.is_speaking()
  return queue.is_speaking()
end

return M
