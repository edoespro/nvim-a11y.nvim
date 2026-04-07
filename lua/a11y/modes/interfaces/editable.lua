-- lua/a11y/modes/interfaces/editable.lua
-- Contrato de edición que comparten modo Normal e Insert.
-- Opera sobre el portapapeles del sistema, no los registros
-- internos de Neovim.
-- Requiere xclip, xsel o termux-clipboard-get/set disponible.

local M = {}

-- ─────────────────────────────────────────
-- Verificación de contrato
-- ─────────────────────────────────────────

local required_methods = {
  "edit_copy",
  "edit_cut",
  "edit_paste",
  "edit_delete",
  "edit_undo",
  "edit_redo",
}

function M.verify(mode)
  for _, method in ipairs(required_methods) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar '%s' (interface Editable)",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- ─────────────────────────────────────────
-- Utilería de portapapeles del sistema
-- Compartida por todos los modos que implementen Editable
-- ─────────────────────────────────────────

-- Copia texto al portapapeles del sistema via termux-clipboard-set
function M.clipboard_set(text)
  if not text or text == "" then return false end

  local ok = vim.system(
    { "termux-clipboard-set", text },
    { detach = false }
  ):wait()

  return ok.code == 0
end

-- Obtiene texto del portapapeles del sistema via termux-clipboard-get
function M.clipboard_get()
  local result = vim.system(
    { "termux-clipboard-get" },
    { detach = false }
  ):wait()

  if result.code == 0 then
    return result.stdout or ""
  end

  return ""
end

-- ─────────────────────────────────────────
-- Contrato de métodos
-- ─────────────────────────────────────────

-- Copia la selección activa o elemento bajo cursor
-- al portapapeles del sistema
function M.edit_copy(self)
  error(self.name .. " debe implementar edit_copy()")
end

-- Corta la selección activa o elemento bajo cursor
-- al portapapeles del sistema
function M.edit_cut(self)
  error(self.name .. " debe implementar edit_cut()")
end

-- Pega el contenido del portapapeles del sistema
-- en la posición actual del cursor
function M.edit_paste(self)
  error(self.name .. " debe implementar edit_paste()")
end

-- Borra la selección activa o carácter bajo cursor
-- sin afectar el portapapeles
function M.edit_delete(self)
  error(self.name .. " debe implementar edit_delete()")
end

-- Deshace el último cambio
function M.edit_undo(self)
  error(self.name .. " debe implementar edit_undo()")
end

-- Rehace el último cambio deshecho
function M.edit_redo(self)
  error(self.name .. " debe implementar edit_redo()")
end

return M
