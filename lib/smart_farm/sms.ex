defmodule SmartFarm.SMS do
  def send(phone_number, message) when is_binary(phone_number) do
    AtEx.Sms.send_sms(%{to: format_phone_number(phone_number), message: message})
  end

  defp format_phone_number("254" <> rest) when byte_size(rest) == 9 do
    "+254" <> rest
  end

  defp format_phone_number("0" <> rest) when byte_size(rest) == 9 do
    "+254" <> rest
  end

  defp format_phone_number("0254" <> rest) when byte_size(rest) == 9 do
    "+254" <> rest
  end

  defp format_phone_number(number) when byte_size(number) == 9 do
    "+254" <> number
  end

  defp format_phone_number(number) do
    number
  end
end
