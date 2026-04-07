-- lua/a11y/modes/interfaces/navigable.lua
-- Contrato de navegación que comparten modo Normal e Insert.
-- Define los métodos de navegación por caracteres, palabras,
-- líneas, párrafos, página e inicio/fin de archivo y línea.

local M = {}

-- ─────────────────────────────────────────
-- Verificación de contrato
-- ─────────────────────────────────────────

local required_methods = {
  "navigate_char",
  "navigate_word",
  "navigate_line",
  "navigate_paragraph",
  "navigate_page",
  "navigate_line_start",
  "navigate_line_end",
  "navigate_file_start",
  "navigate_file_end",
}

function M.verify(mode)
  for _, method in ipairs(required_methods) do
    if type(mode[method]) ~= "function" then
      error(string.format(
        "[a11y] El modo '%s' debe implementar '%s' (interface Navigable)",
        mode.name or "desconocido",
        method
      ))
    end
  end
end

-- ─────────────────────────────────────────
-- Contrato de métodos
-- ─────────────────────────────────────────

-- Navega un carácter en la dirección dada
-- direction: "left" | "right"
function M.navigate_char(self, direction)
  error(self.name .. " debe implementar navigate_char(direction)")
end

-- Navega una palabra en la dirección dada
-- direction: "left" | "right"
function M.navigate_word(self, direction)
  error(self.name .. " debe implementar navigate_word(direction)")
end

-- Navega una línea en la dirección dada
-- direction: "up" | "down"
function M.navigate_line(self, direction)
  error(self.name .. " debe implementar navigate_line(direction)")
end

-- Navega un párrafo en la dirección dada
-- direction: "up" | "down"
function M.navigate_paragraph(self, direction)
  error(self.name .. " debe implementar navigate_paragraph(direction)")
end

-- Navega media pantalla en la dirección dada
-- direction: "up" | "down"
function M.navigate_page(self, direction)
  error(self.name .. " debe implementar navigate_page(direction)")
end

-- Mueve el cursor al inicio de la línea actual
function M.navigate_line_start(self)
  error(self.name .. " debe implementar navigate_line_start()")
end

-- Mueve el cursor al fin de la línea actual
function M.navigate_line_end(self)
  error(self.name .. " debe implementar navigate_line_end()")
end

-- Mueve el cursor al inicio del archivo
function M.navigate_file_start(self)
  error(self.name .. " debe implementar navigate_file_start()")
end

-- Mueve el cursor al fin del archivo
function M.navigate_file_end(self)
  error(self.name .. " debe implementar navigate_file_end()")
end

return M
