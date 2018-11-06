defmodule UrlShortener.Adapters.Http.Schemas.CreateUrl do
  use Ecto.Schema
  alias Ecto.Changeset

  embedded_schema do
    field(:long, :string)
  end

  defmodule Uri do
    @moduledoc """
    Schema for validatin the Urls from user input
    """
    use Ecto.Schema

    embedded_schema do
      field(:scheme, :string)
      field(:host, :string)
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> Changeset.cast(params, [:scheme, :host])
      |> Changeset.validate_required([:scheme, :host])
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Changeset.cast(params, [:long])
    |> Changeset.validate_required([:long])
    |> validate_uri(:long, Uri)
  end

  def validate_uri(changeset, field, schema) do
    with value when is_binary(value) <- Changeset.get_field(changeset, field),
         uri = URI.parse(value),
         uri_changeset = schema.changeset(struct(schema), Map.from_struct(uri)),
         %{valid?: true} <- uri_changeset do
      changeset
    else
      nil ->
        changeset

      %{valid?: false} = uri_changeset ->
        uri_changeset
        |> Changeset.traverse_errors(fn _, field, {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace("#{field} #{acc}", "%{#{key}}", to_string(value))
          end)
        end)
        |> Enum.reduce(changeset, fn {_, msgs}, acc ->
          Enum.reduce(msgs, acc, fn msg, acc ->
            Changeset.add_error(acc, field, msg)
          end)
        end)
    end
  end
end
