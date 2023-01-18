defmodule SmartFarm.SMS do
  alias SmartFarm.SMS.AtClient

  def send(phone_number, message) when is_binary(phone_number) do
    config = Application.get_env(:smart_farm, :africastalking)

    attrs = %{
      to: format_phone_number(phone_number),
      message: message,
      username: config[:username],
      from: config[:shortcode]
    }

    case AtClient.post("/messaging", attrs) do
      {:ok, %{status: status, body: body}} when status >= 200 and status <= 300 ->
        {:ok, body}

      {:ok, %{body: body}} ->
        {:error, body}

      other ->
        other
    end
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
