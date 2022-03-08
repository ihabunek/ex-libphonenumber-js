# LibPhoneNumber

Provides parsing and formatting phone numbers.

An Elixir wrapper around
[libphonenumber-js](https://gitlab.com/catamphetamine/libphonenumber-js). Runs a
small Node server which exposes a subset of libphonenumber-js functionality to
Elixir.

Requires Node.

**Motivation**: Makes it possible to use the same library for phone number
  manipulation in server and client code, reducing the possiblity of different
  behaviours between the two.

**Status**: Under development. Anything can change.

## Overview

* [Source code](https://github.com/ihabunek/ex_libphonenumber_js/)
* [Documentation](https://hexdocs.pm/parent/libphonenumber_js)
* License: Apache License Version 2.0

## Quick start

Start the server before using.

```elixir
iex> LibPhoneNumber.start_link(nil)
{:ok, #PID<0.240.0>}
```

### Parsing

National formatted numbers, requires a country code as second argument.

```elixir
iex> LibPhoneNumber.parse("(814) 300-8073", "US")
{:ok,
 %LibPhoneNumber.Parsed{
   country: "US",
   country_calling_code: "1",
   national_number: "8143008073",
   number: "+18143008073",
   type: :fixed_line_or_mobile,
   valid?: true
 }}
```

E164 formatted international numbers, does not require country code.

```elixir
iex> LibPhoneNumber.parse("+385991234567")
{:ok,
 %LibPhoneNumber.Parsed{
   country: "HR",
   country_calling_code: "385",
   national_number: "991234567",
   number: "+385991234567",
   type: :mobile,
   valid?: true
 }}
```

Returns an error if number cannot be parsed.

```elixir
iex> LibPhoneNumber.parse("0991", "HR")
{:error, :too_short}

iex> LibPhoneNumber.parse("099123456789", "HR")
{:error, :too_long}

iex> LibPhoneNumber.parse("banana", "HR")
{:error, :not_a_number}

iex(3)> LibPhoneNumber.parse("123", "mango")
{:error, :invalid_country}
```

### Formatting numbers

`format` takes an E.164 formatted phone number and formats it to one of the
supported format templates.

```elixir
iex> LibPhoneNumber.format("+18143008073")
{:ok, "(814) 300-8073"}

iex> LibPhoneNumber.format("+18143008073", :national)
{:ok, "(814) 300-8073"}

iex> LibPhoneNumber.format("+18143008073", :international)
{:ok, "+1 814 300 8073"}

iex> LibPhoneNumber.format("+18143008073", :e164)
{:ok, "+18143008073"}

iex> LibPhoneNumber.format("+18143008073", :rfc3966)
{:ok, "tel:+18143008073"}
```

Returns the same errors as `parse` with the addition of `:invalid_format`.

```elixir
iex> LibPhoneNumber.format("+18143008073", :kiwi)
{:error, :invalid_format}
```

## Upgrading to a newer version of libphonenumber-js

Not required for normal usage, this is the procedure for creating a new release
of LibPhoneNumber from a new version of the underlying javascript library.

Requires [esbuild](https://esbuild.github.io/).

```sh
# Check for new versions
npm outdated

# Upgrade javascript library to latest version
npm install libphonenumber-js@latest

# Generate the javascript bundle
make bundle
```

Commit, tag, package, publish.
