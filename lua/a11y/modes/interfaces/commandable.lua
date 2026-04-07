-- lua/a11y/modes/interfaces/commandable.lua
-- Contrato para el modo Command.
-- Define los métodos para gestionar la línea de comandos:
-- eco de caracteres, autocompletado, errores y cancelación.

local M = {}

-- ─────────────────────────────────────────
-- Verificación de contrato
-- ─────────────────────────────────────────

local required_methods = {
  "on_cmdline_changed",
  "on_cmdline_enter",
  "on_cmdline_leave",
  "on_completion",
  "on_cmdline_cancel",
  "on_cmdline_error",
}

function M.verify(mode)
  for _, method in ipairs(required_methods) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar '%s' (interface Commandable)",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- ─────────────────────────────────────────
-- Contrato de métodos
-- ─────────────────────────────────────────

-- Llamado cuando cambia el contenido de la línea de comandos.
-- content : string con el contenido actual completo
function M.on_cmdline_changed(self, content)
  error(self.name .. " debe implementar on_cmdline_changed(content)")
end

-- Llamado cuando el usuario presiona Enter en la línea de comandos.
-- content : string con el comando completo
-- cmdtype : ":" | "/" | "?" | "!"
function M.on_cmdline_enter(self, content, cmdtype)
  error(self.name .. " debe implementar on_cmdline_enter(content, cmdtype)")
end

-- Llamado cuando el usuario sale de la línea de comandos.
-- executed : boolean, true si se ejecutó, false si se canceló
function M.on_cmdline_leave(self, executed)
  error(self.name .. " debe implementar on_cmdline_leave(executed)")
end

-- Llamado cuando el usuario presiona Tab para autocompletar.
-- matches  : tabla con las opciones disponibles
-- selected : string con la opción actualmente seleccionada
function M.on_completion(self, matches, selected)
  error(self.name .. " debe implementar on_completion(matches, selected)")
end

-- Llamado cuando el usuario cancela con Escape.
function M.on_cmdline_cancel(self)
  error(self.name .. " debe implementar on_cmdline_cancel()")
end

-- Llamado cuando ocurre un error en el comando ejecutado.
-- message : string con el mensaje de error de Neovim
function M.on_cmdline_error(self, message)
  error(self.name .. " debe implementar on_cmdline_error(message)")
end

return M
