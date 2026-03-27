-- lua/a11y/formatter.lua
-- Responsabilidad: convertir datos crudos del editor en
-- texto legible y significativo para verbalizar
-- No conoce al TTS ni a los modos, solo formatea texto

local M = {}

-- ─────────────────────────────────────────
-- Formato de navegación
-- ─────────────────────────────────────────

-- Formatea un carácter individual para verbalizarlo
-- Convierte caracteres especiales en palabras descriptivas
function M.char(c)
  if c == nil or c == "" then return "fin de línea" end

  local special = {
    [" "]  = "espacio",
    ["\t"] = "tabulación",
    ["\n"] = "nueva línea",
    ["."]  = "punto",
    [","]  = "coma",
    [";"]  = "punto y coma",
    [":"]  = "dos puntos",
    ["("]  = "paréntesis abre",
    [")"]  = "paréntesis cierra",
    ["{"]  = "llave abre",
    ["}"]  = "llave cierra",
    ["["]  = "corchete abre",
    ["]"]  = "corchete cierra",
    ["<"]  = "menor que",
    [">"]  = "mayor que",
    ["="]  = "igual",
    ["+"]  = "más",
    ["-"]  = "menos",
    ["*"]  = "asterisco",
    ["/"]  = "diagonal",
    ["\\"] = "diagonal inversa",
    ["\""] = "comilla doble",
    ["'"]  = "comilla simple",
    ["`"]  = "acento grave",
    ["#"]  = "numeral",
    ["@"]  = "arroba",
    ["$"]  = "dólar",
    ["!"]  = "exclamación",
    ["?"]  = "interrogación",
    ["&"]  = "ampersand",
    ["|"]  = "barra vertical",
    ["_"]  = "guión bajo",
    ["%"]  = "porcentaje",
    ["^"]  = "circunflejo",
    ["~"]  = "tilde",
  }

  return special[c] or c
end

-- Formatea una línea completa
-- Incluye número de línea si se solicita
function M.line(lnum, text, opts)
  opts = opts or {}
  text = text or ""

  -- Línea vacía
  if text:match("^%s*$") then
    if opts.show_line_number then
      return "línea " .. lnum .. ", vacía"
    end
    return "línea vacía"
  end

  -- Línea con contenido
  if opts.show_line_number then
    return "línea " .. lnum .. ": " .. text
  end

  return text
end

-- Formatea la posición actual del cursor
function M.position(lnum, col, total_lines)
  return string.format(
    "línea %d de %d, columna %d",
    lnum,
    total_lines or lnum,
    col
  )
end

-- ─────────────────────────────────────────
-- Formato de modos
-- ─────────────────────────────────────────

local mode_names = {
  normal           = "modo normal",
  insert           = "modo inserción",
  visual           = "modo visual",
  visual_line      = "modo visual línea",
  visual_block     = "modo visual bloque",
  command          = "modo comando",
  operator_pending = "operador pendiente",
  terminal         = "modo terminal",
  replace          = "modo reemplazo",
}

function M.mode(mode_name)
  return mode_names[mode_name] or mode_name
end

-- ─────────────────────────────────────────
-- Formato de diagnósticos LSP
-- ─────────────────────────────────────────

local severity_names = {
  [1] = "error",
  [2] = "advertencia",
  [3] = "información",
  [4] = "sugerencia",
}

function M.diagnostic(diag)
  local severity = severity_names[diag.severity] or "diagnóstico"
  return string.format(
    "%s en línea %d: %s",
    severity,
    (diag.lnum or 0) + 1,
    diag.message or ""
  )
end

-- ─────────────────────────────────────────
-- Formato de archivos y buffers
-- ─────────────────────────────────────────

function M.file_opened(filename)
  return "archivo: " .. (filename or "sin nombre")
end

function M.file_saved(filename)
  return "guardado: " .. (filename or "sin nombre")
end

function M.buffer_changed(filename)
  return "buffer: " .. (filename or "sin nombre")
end

-- ─────────────────────────────────────────
-- Formato de comandos
-- ─────────────────────────────────────────

function M.command(cmdtype, content)
  local type_names = {
    [":"] = "comando",
    ["/"] = "búsqueda adelante",
    ["?"] = "búsqueda atrás",
    ["!"] = "shell",
  }
  local name = type_names[cmdtype] or "comando"
  return name .. ": " .. (content or "")
end

function M.command_error(message)
  return "error: " .. (message or "comando inválido")
end

-- ─────────────────────────────────────────
-- Formato de operadores pendientes
-- ─────────────────────────────────────────

local operator_names = {
  f = "buscar carácter",
  t = "hasta carácter",
  r = "reemplazar con",
  d = "borrar",
  c = "cambiar",
  y = "copiar",
}

function M.operator(op, target)
  local name = operator_names[op] or op
  if target then
    return name .. " " .. target
  end
  return name .. ", esperando"
end

return M
