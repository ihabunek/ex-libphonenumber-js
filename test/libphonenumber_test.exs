defmodule LibPhoneNumberTest do
  use ExUnit.Case
  doctest LibPhoneNumber

  alias LibPhoneNumber.Parsed

  import LibPhoneNumber, only: [parse: 1, parse: 2, format: 1, format: 2]

  describe "parse" do
    test "parsing national numbers" do
      assert {:ok, _pid} = LibPhoneNumber.start_link(nil)

      # Valid number
      assert {:ok, parsed} = parse("(484) 4608-058", "US")

      assert parsed == %Parsed{
               country: "US",
               country_calling_code: "1",
               national_number: "4844608058",
               number: "+14844608058",
               type: :fixed_line_or_mobile,
               valid?: true
             }

      # Invalid number
      assert {:ok, parsed} = parse("(555) 1234-567", "US")

      assert parsed == %Parsed{
               country: "US",
               country_calling_code: "1",
               national_number: "5551234567",
               number: "+15551234567",
               type: :unknown,
               valid?: false
             }

      assert {:error, :invalid_country} = parse("(555) 1234-567", nil)
      assert {:error, :invalid_country} = parse("(555) 1234-567", "")
      assert {:error, :invalid_country} = parse("(555) 1234-567", "XX")
      assert {:error, :too_short} = parse("555", "US")
      assert {:error, :too_long} = parse("(555) 1234-567-890", "US")
      assert {:error, :not_a_number} = parse("", "US")
      assert {:error, :not_a_number} = parse("banana", "US")
      assert {:error, :invalid_length} = parse("444 1 4444", "TR")

      # Currently giving a non-string number or country returns :unknown error
      # TODO: this could be improved by checking type in Elixir before calling node
      assert {:error, :unknown} = parse(100, "US")
      assert {:error, :unknown} = parse(true, "US")
      assert {:error, :unknown} = parse("(555) 1234-567", 100)
      assert {:error, :unknown} = parse("(555) 1234-567", true)
    end

    test "parsing international numbers" do
      assert {:ok, _pid} = LibPhoneNumber.start_link(nil)
      assert {:ok, parsed} = parse("+385991234567")

      assert parsed == %Parsed{
               country: "HR",
               country_calling_code: "385",
               national_number: "991234567",
               number: "+385991234567",
               type: :mobile,
               valid?: true
             }

      # Given country code is ignored
      assert {:ok, parsed} = parse("+385991234567", "US")

      assert parsed == %Parsed{
               country: "HR",
               country_calling_code: "385",
               national_number: "991234567",
               number: "+385991234567",
               type: :mobile,
               valid?: true
             }

      assert {:error, :too_short} = parse("+38599123")
      assert {:error, :too_long} = parse("+38599123456789")
      assert {:error, :not_a_number} = parse("+")
      assert {:error, :invalid_country} = parse("+01234567")
    end
  end

  describe "format" do
    test "various formats" do
      assert {:ok, _pid} = LibPhoneNumber.start_link(nil)

      assert format("+385991234567") == {:ok, "099 123 4567"}
      assert format("+385991234567", :national) == {:ok, "099 123 4567"}
      assert format("+385991234567", :international) == {:ok, "+385 99 123 4567"}
      assert format("+385991234567", :e164) == {:ok, "+385991234567"}
      assert format("+385991234567", :rfc3966) == {:ok, "tel:+385991234567"}

      assert format("+15551234567") == {:ok, "(555) 123-4567"}
      assert format("+15551234567", :national) == {:ok, "(555) 123-4567"}
      assert format("+15551234567", :international) == {:ok, "+1 555 123 4567"}
      assert format("+15551234567", :e164) == {:ok, "+15551234567"}
      assert format("+15551234567", :rfc3966) == {:ok, "tel:+15551234567"}

      assert format("") == {:error, :not_a_number}
      assert format("foo") == {:error, :not_a_number}
      assert format("1234567890") == {:error, :invalid_country}
      assert format("+12345") == {:error, :too_short}
      assert format("+1234567890123") == {:error, :too_long}
      assert format("+385991234567", :foo) == {:error, :invalid_format}
      assert format("+385991234567", :foo) == {:error, :invalid_format}
    end
  end
end
