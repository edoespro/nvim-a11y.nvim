-- lua/a11y/modes/interfaces/selectable.lua
-- Contrato de selección que comparten modo Visual e Insert.
-- Define los métodos de selección por carácter, palabra,
-- línea, párrafo y todo el archivo.

local M = {}

-- ─────────────────────────────────────────
-- Verificación de contrato
-- ─────────────────────────────────────────

local required_methods = {
  "select_char",
  "select_word",
  "select_line",
  "select_paragraph",
  "select_all",
  "select_clear",
}

function M.verify(mode)
  for _, method in ipairs(required_methods) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar '%s' (interface Selectable)",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- ─────────────────────────────────────────
-- Contrato de métodos
-- ─────────────────────────────────────────

-- Selecciona el carácter bajo el cursor
function M.select_char(self)
  error(self.name .. " debe implementar select_char()")
end

-- Selecciona la palabra bajo el cursor
function M.select_word(self)
  error(self.name .. " debe implementar select_word()")
end

-- Selecciona la línea completa bajo el cursor
function M.select_line(self)
  error(self.name .. " debe implementar select_line()")
end

-- Selecciona el párrafo bajo el cursor
function M.select_paragraph(self)
  error(self.name .. " debe implementar select_paragraph()")
end

-- Selecciona todo el contenido del buffer
function M.select_all(self)
  error(self.name .. " debe implementar select_all()")
end

-- Cancela la selección activa
function M.select_clear(self)
  error(self.name .. " debe implementar select_clear()")
end

return M
