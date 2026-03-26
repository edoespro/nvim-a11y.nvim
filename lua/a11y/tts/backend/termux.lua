-- lua/a11y/tts/backend/termux.lua
-- Responsabilidad única: ejecutar y cancelar procesos termux-tts-speak
-- No conoce colas, filtros ni prioridades

local M = {}

-- Verifica que termux-tts-speak está disponible en el sistema
function M.is_available()
  return vim.fn.executable("termux-tts-speak") == 1
end

-- Ejecuta termux-tts-speak de forma asíncrona
-- Devuelve el job para poder cancelarlo
-- on_done: función callback que se llama al terminar
function M.speak(text, on_done)
  if not M.is_available() then
    vim.notify("[a11y] termux-tts-speak no está disponible", vim.log.levels.ERROR)
    return nil
  end

  local job = vim.system(
    { "termux-tts-speak", text },
    { detach = false },
    vim.schedule_wrap(function(result)
      if on_done then
        on_done(result)
      end
    end)
  )

  return job
end

-- Cancela un job en curso
function M.cancel(job)
  if job and not job:is_closing() then
    job:kill(9)
  end
end

return M
