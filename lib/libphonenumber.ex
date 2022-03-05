defmodule Libphonenumber do
  use GenServer
  require Logger

  @type parse_error ::
          :invalid_country
          | :invalid_length
          | :not_a_number
          | :too_long
          | :too_short
          | :unknown

  @type number_type ::
          :mobile
          | :fixed_line
          | :fixed_line_or_mobile
          | :premium_rate
          | :toll_free
          | :shared_cost
          | :voip
          | :personal_number
          | :pager
          | :uan
          | :voicemail
          | :unknown

  defmodule Parsed do
    @type t :: %{
            country_calling_code: String.t(),
            national_number: String.t(),
            number: String.t(),
            country: String.t(),
            valid?: boolean(),
            type: Libphonenumber.number_type()
          }

    defstruct ~w/country_calling_code national_number number country valid? type/a
  end

  # ----------------------------------------------------------------------------
  # Client
  # ----------------------------------------------------------------------------

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec parse(String.t(), String.t()) :: {:ok, Parsed.t()} | {:error, parse_error()}
  def parse(number, country \\ "") do
    GenServer.call(__MODULE__, {:parse, number, country})
  end

  # ----------------------------------------------------------------------------
  # Server
  # ----------------------------------------------------------------------------

  @impl GenServer
  def init(_) do
    path = bundle_path()

    port = Port.open({:spawn, "node #{path}"}, [:binary])
    {:ok, port}
  end

  defp bundle_path() do
    path = __DIR__ |> Path.join("../assets/bundle.cjs") |> Path.expand()
    File.exists?(path) || raise "Bundle not found, run `make bundle` to generate it."
    path
  end

  @impl GenServer
  def handle_call({:parse, number, country}, _from, port) do
    payload = Jason.encode!(["parse", number, country])
    Port.command(port, "#{payload}\n")

    result =
      receive do
        {^port, {:data, response}} ->
          [success?, result] = Jason.decode!(response)

          if success?,
            do: {:ok, to_parsed(result)},
            else: {:error, to_parse_error(result)}
      end

    {:reply, result, port}
  end

  defp to_parsed(result) do
    %Parsed{
      country_calling_code: result["countryCallingCode"],
      national_number: result["nationalNumber"],
      number: result["number"],
      country: result["country"],
      valid?: result["isValid"],
      type: to_type(result["type"])
    }
  end

  defp to_parse_error(string) do
    case string do
      "INVALID_COUNTRY" -> :invalid_country
      "INVALID_LENGTH" -> :invalid_length
      "NOT_A_NUMBER" -> :not_a_number
      "TOO_LONG" -> :too_long
      "TOO_SHORT" -> :too_short
      _ -> :unknown
    end
  end

  defp to_type(string) do
    case string do
      "MOBILE" -> :mobile
      "FIXED_LINE" -> :fixed_line
      "FIXED_LINE_OR_MOBILE" -> :fixed_line_or_mobile
      "PREMIUM_RATE" -> :premium_rate
      "TOLL_FREE" -> :toll_free
      "SHARED_COST" -> :shared_cost
      "VOIP" -> :voip
      "PERSONAL_NUMBER" -> :personal_number
      "PAGER" -> :pager
      "UAN" -> :uan
      "VOICEMAIL" -> :voicemail
      _ -> :unknown
    end
  end
end
