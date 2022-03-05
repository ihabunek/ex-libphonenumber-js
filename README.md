# Libphonenumber

An Elixir wrapper around [libphonenumber-js](https://gitlab.com/catamphetamine/libphonenumber-js). Runs a small Node server which exposes libphonenumber-js functionality to Elixir. Requires Node.

**STATUS**: In development. Anything can change, no releases, no docs.

## Installation (TODO)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `libphonenumber` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:libphonenumber, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/libphonenumber>.

## Usage

```elixir
iex> Libphonenumber.start_link(nil)
{:ok, #PID<0.240.0>}

# Parsing national numbers
iex> Libphonenumber.parse("(814) 300-8073", "US")
{:ok,
 %Libphonenumber.Parsed{
   country: "US",
   country_calling_code: "1",
   national_number: "8143008073",
   number: "+18143008073",
   type: :fixed_line_or_mobile,
   valid?: true
 }}


# Parsing E164 formatted international numbers
iex> Libphonenumber.parse("+385991234567")
{:ok,
 %Libphonenumber.Parsed{
   country: "HR",
   country_calling_code: "385",
   national_number: "991234567",
   number: "+385991234567",
   type: :mobile,
   valid?: true
 }}

# Returns invalid numbers (e.g. US area code 555 does not exist)
iex> Libphonenumber.parse("(555) 1234-567", "US")
atom: nil
{:ok,
 %Libphonenumber.Parsed{
   country: "US",
   country_calling_code: "1",
   national_number: "5551234567",
   number: "+15551234567",
   type: :unknown,
   valid?: false
 }}

# Returns errors
iex> Libphonenumber.parse("123", "HR")
{:error, :too_short}

iex> Libphonenumber.parse("banana")
{:error, :not_a_number}
```

## Upgrading to a newer version of libphonenumber-js

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
