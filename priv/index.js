import { createInterface } from "readline"
import { parsePhoneNumber, validatePhoneNumberLength } from 'libphonenumber-js/max'

const rl = createInterface({ input: process.stdin, terminal: false })

rl.on("line", line => {
  const [command, ...args] = JSON.parse(line)

  switch (command) {
    case "parse":
      process.stdout.write(parse(...args))
      break

    case "format":
      process.stdout.write(format(...args))
      break

    default:
      process.stdout.write(error_response())
  }
})

function parse(number = "", defaultCountry = "") {
  try {
    const error = validatePhoneNumberLength(number, defaultCountry)
    if (error) {
      return error_response(error)
    }

    const parsed = parsePhoneNumber(number, defaultCountry)
    return ok_response({
      countryCallingCode: parsed.countryCallingCode,
      nationalNumber: parsed.nationalNumber,
      number: parsed.number,
      country: parsed.country,
      isValid: parsed.isValid(),
      type: parsed.getType(),
    })
  } catch (error) {
    // log(`[libphonenumber-js] ${error}`)
    return error_response()
  }
}

function format(number = "", format = "") {
  try {
    const error = validatePhoneNumberLength(number)
    if (error) {
      return error_response(error)
    }

    const parsed = parsePhoneNumber(number)
    const formatted = parsed.format(format)
    return ok_response(formatted)
  } catch (error) {
    return error_response()
  }
}

const ok_response = result => JSON.stringify([true, result]) + "\n"
const error_response = error => JSON.stringify([false, error]) + "\n"

// Logging to stderr doesn't pipe the output back to elixir
const log = string => process.stderr.write(string + "\n")
