-- lua/a11y/modes/interfaces/base.lua
-- Contrato base que todos los modos deben cumplir.
-- Define el ciclo de vida, manejo de eventos crudos de Neovim
-- y el sistema interno de suscripción a eventos propios del modo.

local M = {}

-- ─────────────────────────────────────────
-- Verificación de contrato
-- ─────────────────────────────────────────

-- Métodos obligatorios que todo modo debe implementar
local required_methods = {
  "on_enter",
  "on_exit",
  "on_key",
  "on_cursor_moved",
  "context",
  "subscribe",
}

-- Verifica que un modo implementa todos los métodos requeridos.
-- Lanza error descriptivo en tiempo de carga si falta alguno.
function M.verify(mode)
  for _, method in ipairs(required_methods) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar el método '%s' (interface Base)",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- ─────────────────────────────────────────
-- Sistema de suscripción reutilizable
-- Cualquier modo puede usar esta función para
-- construir su tabla interna de listeners
-- ─────────────────────────────────────────

-- Crea y devuelve una tabla de listeners vacía.
-- Cada modo llama a esto en su inicialización.
function M.new_listeners()
  return {}
end

-- Registra un handler para un evento propio del modo.
-- Soporta múltiples handlers por evento.
-- listeners : tabla de listeners del modo
-- event     : nombre del evento (ej: "line_changed")
-- handler   : función a ejecutar cuando ocurra el evento
function M.on(listeners, event, handler)
  if type(handler) ~= "function" then
    error(string.format(
      "[a11y] El handler para '%s' debe ser una función",
      event
    ))
  end

  if not listeners[event] then
    listeners[event] = {}
  end

  table.insert(listeners[event], handler)
end

-- Despacha un evento a todos sus handlers registrados.
-- listeners : tabla de listeners del modo
-- event     : nombre del evento a despachar
-- data      : datos puros del evento (sin texto TTS ni prioridad)
function M.dispatch(listeners, event, data)
  if not listeners[event] then return end

  for _, handler in ipairs(listeners[event]) do
    handler(data)
  end
end

return M
