import { createInterface } from "readline"
import { validatePhoneNumberLength, parsePhoneNumber } from 'libphonenumber-js/max'

const int = createInterface({ input: process.stdin, terminal: false })

int.on("line", line => {
  const [command, ...args] = JSON.parse(line)

  switch (command) {
    case "parse":
      const response = parse(...args)
      process.stdout.write(response)
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

    const parsed = parsePhoneNumber(number, {defaultCountry})
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

const ok_response = result => JSON.stringify([true, result]) + "\n"
const error_response = error => JSON.stringify([false, error]) + "\n"

// Logging to stderr doesn't pipe the output back to elixir
const log = string => process.stderr.write(string + "\n")
