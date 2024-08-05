defmodule Chocolatey do
  def install_package(package, current_packages) do
    # Check if the package is already installed
    case Map.get(current_packages, package) do
      nil ->
        # Run the Chocolatey install command
        {output, exit_code} = System.cmd("choco", ["install", package, "-y"])

        # Handle the command output based on the exit code
        case exit_code do
          0 ->
            IO.puts("Successfully installed #{package}")
            output
          _ ->
            IO.puts("Failed to install #{package}")
            IO.puts("Error: #{output}")
            output
        end
      _ ->
        upgrade_package(package)
        "Package #{package} is already installed, upgrading to latest version."
    end
  end

  def uninstall_package(package, current_packages) do
    case Map.get(current_packages, package) do
      nil ->
        "Package #{package} is not installed."

      _ ->
        # Run the Chocolatey uninstall command
        {output, exit_code} = System.cmd("choco", ["uninstall", package, "-y"])

        # Handle the command output based on the exit code
        case exit_code do
          0 ->
            IO.puts("Successfully uninstalled #{package}")

            # Check if there is a corresponding .install package and uninstall it
            install_package = "#{package}.install"
            case Map.get(current_packages, install_package) do
              nil -> :ok
              _ ->
                {install_output, install_exit_code} = System.cmd("choco", ["uninstall", install_package, "-y"])
                case install_exit_code do
                  0 ->
                    IO.puts("Successfully uninstalled #{install_package}")
                  _ ->
                    IO.puts("Failed to uninstall #{install_package}")
                    IO.puts("Error: #{install_output}")
                end
            end

            output
          _ ->
            IO.puts("Failed to uninstall #{package}")
            IO.puts("Error: #{output}")
            output
        end
    end
  end

  def upgrade_package(package) do
    # Run the Chocolatey upgrade command
    {output, exit_code} = System.cmd("choco", ["upgrade", package, "-y"])

    # Handle the command output based on the exit code
    case exit_code do
      0 ->
        IO.puts("Successfully upgraded #{package}")
        output
      _ ->
        IO.puts("Failed to upgrade #{package}")
        IO.puts("Error: #{output}")
        output
    end
  end

  def upgrade_all_packages do
    # Run the Chocolatey upgrade all command
    {output, exit_code} = System.cmd("choco", ["upgrade", "all", "-y"])

    # Handle the command output based on the exit code
    case exit_code do
      0 ->
        IO.puts("Successfully upgraded all packages")
        output
      _ ->
        IO.puts("Failed to upgrade all packages")
        IO.puts("Error: #{output}")
        output
    end
  end

  def get_current_packages do
    # Run the Chocolatey list command
    {output, exit_code} = System.cmd("choco", ["list"])

    # Handle the command output based on the exit code
    case exit_code do
      0 ->
        # Split the output into lines, filter out unwanted lines, and parse each line
        packages =
          output
          |> String.split("\n")
          |> Enum.filter(fn line ->
            not (String.contains?(line, "Chocolatey v") or String.contains?(line, "packages installed"))
          end)
          |> Enum.reduce(%{}, fn line, acc ->
            case String.split(line, " ") do
              [name, version | _] -> Map.put(acc, name, String.trim(version))
              _ -> acc
            end
          end)

        # Return the map of package names and versions
        packages

      _ ->
        IO.puts("Failed to get current Chocolatey packages")
        IO.puts("Error: #{output}")
        output
    end
  end
end

IO.inspect(Chocolatey.get_current_packages())
Chocolatey.install_package("git", Chocolatey.get_current_packages())
IO.inspect(Chocolatey.get_current_packages())
Chocolatey.upgrade_package("git")
Chocolatey.uninstall_package("git", Chocolatey.get_current_packages())
IO.inspect(Chocolatey.get_current_packages())
Chocolatey.upgrade_all_packages()
