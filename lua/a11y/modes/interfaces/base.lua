-- lua/a11y/modes/interfaces/base.lua
-- Contrato que todos los modos deben cumplir
-- Define los métodos obligatorios del ciclo de vida
-- y manejo de eventos crudos de Neovim

local M = {}
-- Verifica que un modo implementa todos los métodos
-- de esta interfaz. Lanza error descriptivo si falta alguno.
function M.verify(mode)
  local required = {
    "on_enter",
    "on_exit",
    "on_key",
    "on_cursor_moved",
    "context",
    "subscribe",
  }

  for _, method in ipairs(required) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar '%s'",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- Métodos que definen el contrato base
-- Cada modo los sobreescribe con su propia lógica

-- Llamado cuando el modo se activa
function M.on_enter(self)
  error(self.name .. " debe implementar on_enter()")
end

-- Llamado cuando el modo se desactiva
function M.on_exit(self)
  error(self.name .. " debe implementar on_exit()")
end

-- Llamado con cada tecla presionada
function M.on_key(self, key)
  error(self.name .. " debe implementar on_key()")
end

-- Llamado cuando el cursor se mueve
function M.on_cursor_moved(self, pos)
  error(self.name .. " debe implementar on_cursor_moved()")
end

-- Devuelve el estado actual del modo
function M.context(self)
  error(self.name .. " debe implementar context()")
end

-- Registra suscriptores a los eventos propios del modo
function M.subscribe(self, event, handler)
  error(self.name .. " debe implementar subscribe()")
end

return M
