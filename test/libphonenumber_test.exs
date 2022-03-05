defmodule ClusterTest do
  use ExUnit.Case

  describe "parse" do
    test "parsing national numbers" do
      assert {:ok, _pid} = Libphonenumber.start_link(nil)

      # Valid number
      assert {:ok, parsed} = Libphonenumber.parse("(484) 4608-058", "US")

      assert parsed == %Libphonenumber.Parsed{
               country: "US",
               country_calling_code: "1",
               national_number: "4844608058",
               number: "+14844608058",
               type: :fixed_line_or_mobile,
               valid?: true
             }

      # Invalid number
      assert {:ok, parsed} = Libphonenumber.parse("(555) 1234-567", "US")

      assert parsed == %Libphonenumber.Parsed{
               country: "US",
               country_calling_code: "1",
               national_number: "5551234567",
               number: "+15551234567",
               type: :unknown,
               valid?: false
             }

      assert {:error, :invalid_country} = Libphonenumber.parse("(555) 1234-567", nil)
      assert {:error, :invalid_country} = Libphonenumber.parse("(555) 1234-567", "")
      assert {:error, :invalid_country} = Libphonenumber.parse("(555) 1234-567", "XX")
      assert {:error, :too_short} = Libphonenumber.parse("555", "US")
      assert {:error, :too_long} = Libphonenumber.parse("(555) 1234-567-890", "US")
      assert {:error, :not_a_number} = Libphonenumber.parse("", "US")
      assert {:error, :not_a_number} = Libphonenumber.parse("banana", "US")
      assert {:error, :invalid_length} = Libphonenumber.parse("444 1 4444", "TR")

      # Currently giving a non-string number or country returns :unknown error
      # TODO: this could be improved by checking type in Elixir before calling node
      assert {:error, :unknown} = Libphonenumber.parse(100, "US")
      assert {:error, :unknown} = Libphonenumber.parse(true, "US")
      assert {:error, :unknown} = Libphonenumber.parse("(555) 1234-567", 100)
      assert {:error, :unknown} = Libphonenumber.parse("(555) 1234-567", true)
    end

    test "parsing international numbers" do
      assert {:ok, _pid} = Libphonenumber.start_link(nil)
      assert {:ok, parsed} = Libphonenumber.parse("+385991234567")

      assert parsed == %Libphonenumber.Parsed{
               country: "HR",
               country_calling_code: "385",
               national_number: "991234567",
               number: "+385991234567",
               type: :mobile,
               valid?: true
             }

      # Given country code is ignored
      assert {:ok, parsed} = Libphonenumber.parse("+385991234567", "US")

      assert parsed == %Libphonenumber.Parsed{
               country: "HR",
               country_calling_code: "385",
               national_number: "991234567",
               number: "+385991234567",
               type: :mobile,
               valid?: true
             }

      assert {:error, :too_short} = Libphonenumber.parse("+38599123")
      assert {:error, :too_long} = Libphonenumber.parse("+38599123456789")
      assert {:error, :not_a_number} = Libphonenumber.parse("+")
      assert {:error, :invalid_country} = Libphonenumber.parse("+01234567")
    end
  end
end
