defmodule SuperPerfundoWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import SuperPerfundoWeb.Gettext

      # Simple translation
      gettext("Here is the string to translate")

      # Plural translation
      ngettext("Here is the string to translate",
               "Here are the strings to translate",
               3)

      # Domain-based translation
      dgettext("errors", "Here is the error message to translate")

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  # gettext >= 0.26 splits backend definition from use: `use Gettext, otp_app:`
  # is deprecated in favour of `use Gettext.Backend, otp_app:`. Consumers that
  # want the macros call `use Gettext, backend: SuperPerfundoWeb.Gettext` --
  # nothing here does; ErrorHelpers calls Gettext.dgettext/dngettext with an
  # explicit backend instead.
  use Gettext.Backend, otp_app: :super_perfundo
end
