defmodule UrlShortener.Http.Schemas.CreateUrl do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:long, :string)
  end

  defmodule Uri do
    use Ecto.Schema

    embedded_schema do
      field(:scheme, :string)
      field(:host, :string)
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:scheme, :host])
      |> validate_required([:scheme, :host])
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:long])
    |> validate_required([:long])
    |> validate_uri(:long, Uri)
  end

  def validate_uri(changeset, field, schema) do
    with value when is_binary(value) <- get_field(changeset, field),
         uri = URI.parse(value),
         uri_changeset = schema.changeset(struct(schema), Map.from_struct(uri)),
         %{valid?: true} <- uri_changeset do
      changeset
    else
      nil ->
        changeset

      %{valid?: false} = uri_changeset ->
        Ecto.Changeset.traverse_errors(uri_changeset, fn _, field, {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace("#{field} #{acc}", "%{#{key}}", to_string(value))
          end)
        end)
        |> Enum.reduce(changeset, fn {_, msgs}, acc ->
          Enum.reduce(msgs, acc, fn msg, acc ->
            add_error(acc, field, msg)
          end)
        end)
    end
  end
end
